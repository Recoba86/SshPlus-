#!/bin/sh

set -e

# پوشه‌ها را بساز (در صورت نیاز)
mkdir -p /usr/lib/lua/luci/controller
mkdir -p /usr/lib/lua/luci/model/cbi
mkdir -p /usr/lib/lua/luci/view

# ۱. کنترلر LuCI
cat > /usr/lib/lua/luci/controller/sshplus.lua <<"EOF"
module("luci.controller.sshplus", package.seeall)

function index()
    if not nixio.fs.access("/etc/init.d/sshplus") then
        return
    end
    entry({"admin", "services", "sshplus"}, form("sshplus"), "تنظیمات SSHPlus", 90).dependent = true
    entry({"admin", "services", "sshplus_statuspage"}, template("sshplus_statuspage"), "وضعیت SSHPlus", 91).dependent = true
    entry({"admin", "services", "sshplus_status_api"}, call("action_status")).leaf = true
    entry({"admin", "services", "sshplus_toggle"}, call("action_toggle")).leaf = true
end


function action_status()
    local running = false
    local ip = "N/A"
    local uptime = 0

    local handle = io.popen("netstat -tulnp 2>/dev/null | grep 8089 | grep ssh")
    local result = handle:read("*a")
    handle:close()

    if result and result ~= "" then
        running = true
        -- مدت زمان اتصال
        local f = io.open("/tmp/sshplus_start_time", "r")
        if f then
            local start_time = tonumber(f:read("*l") or "0")
            f:close()
            if start_time > 0 then
                uptime = os.time() - start_time
            end
        end
        local ip_handle = io.popen("curl --socks5 127.0.0.1:8089 -s http://ifconfig.me || echo N/A")
        ip = ip_handle:read("*a"):gsub("\n", "")
        ip_handle:close()
    end

    luci.http.prepare_content("application/json")
    luci.http.write_json({running = running, ip = ip, uptime = uptime})
end

function action_toggle()
    local running = false
    local handle = io.popen("netstat -tulnp 2>/dev/null | grep 8089 | grep ssh")
    local result = handle:read("*a")
    handle:close()
    if result and result ~= "" then
        running = true
    end
    if running then
        os.execute("/etc/init.d/sshplus stop")
    else
        os.execute("/etc/init.d/sshplus start")
    end
    luci.http.status(200, "OK")
end
EOF

# ۲. مدل فرم (SimpleForm)
cat > /usr/lib/lua/luci/model/cbi/sshplus.lua <<"EOF"
local fs = require "nixio.fs"
local conf_path = "/etc/sshplus.conf"

local function readval(key)
    if not fs.access(conf_path) then return "" end
    for line in io.lines(conf_path) do
        local k, v = line:match("^(%S+)%=(.*)")
        if k == key then return v end
    end
    return ""
end

local m = SimpleForm("sshplus", "SSHPlus", "مدیریت و کانفیگ SSHPlus")

local host = m:field(Value, "HOST", "SSH Host")
host.default = readval("HOST")

local user = m:field(Value, "USER", "SSH Username")
user.default = readval("USER")

local port = m:field(Value, "PORT", "SSH Port")
port.default = readval("PORT")

local auth = m:field(ListValue, "AUTH_METHOD", "Auth Method")
auth.default = readval("AUTH_METHOD")
auth:value("password", "Password")
auth:value("key", "Private Key")

local pass = m:field(Value, "PASS", "SSH Password (اگر پسوردی)")
pass.password = true
pass.default = readval("PASS")

local keyfile = m:field(Value, "KEY_FILE", "Private Key File (اگر کلید)")
keyfile.default = readval("KEY_FILE")

function m.handle(self, state, data)
    if state == FORM_VALID then
        local new = {
            "HOST=" .. (data.HOST or ""),
            "USER=" .. (data.USER or ""),
            "PORT=" .. (data.PORT or ""),
            "AUTH_METHOD=" .. (data.AUTH_METHOD or ""),
            "PASS=" .. (data.PASS or ""),
            "KEY_FILE=" .. (data.KEY_FILE or "")
        }
        local f = io.open(conf_path, "w+")
        for _, line in ipairs(new) do f:write(line .. "\n") end
        f:close()
        self.message = "✅ تنظیمات با موفقیت ذخیره شد! انتقال به صفحه وضعیت..."
        luci.http.header("Refresh", "1.5; url=" .. luci.dispatcher.build_url("admin/services/sshplus_statuspage"))
    end
    return true
end

return m
EOF

# ۳. مدل statuspage
cat > /usr/lib/lua/luci/model/cbi/sshplus_statuspage.lua <<"EOF"
local Map = require "luci.cbi".Map
local Button = require "luci.cbi".Button
local Value = require "luci.cbi".Value

local m = Map("sshplus_statuspage", "وضعیت SSHPlus", "وضعیت و کنترل سرویس SSHPlus")

-- خواندن وضعیت
local function get_status()
    local running = (os.execute("/etc/init.d/sshplus status >/dev/null 2>&1") == 0)
    local ip = luci.sys.exec("curl --socks5 127.0.0.1:8089 -s http://ifconfig.me || echo N/A")
    return running, ip
end

local running, ip = get_status()
local s = m:section(SimpleSection, "وضعیت کنونی")


s:option(Value, "status", "وضعیت").default = running and "✅ وصل" or "❌ قطع"
s:option(Value, "ip", "IP خروجی").default = ip:gsub("\n", "")

local btn = s:option(Button, "_toggle", running and "⛔ قطع کن" or "▶️ روشن کن")
btn.inputstyle = "apply"

function btn.write()
    luci.http.redirect(luci.dispatcher.build_url("admin/services/sshplus_toggle"))
end

return m
EOF

# ۴. View ساده
cat > /usr/lib/lua/luci/view/sshplus.lua <<"EOF"
local fs = require "nixio.fs"
local conf_path = "/etc/sshplus.conf"
local function readval(key)
    if not fs.access(conf_path) then return "" end
    for line in io.lines(conf_path) do
        local k, v = line:match("^(%S+)%=(.*)")
        if k == key then return v end
    end
    return ""
end
local m = SimpleForm("sshplus", "SSHPlus", "مدیریت و کانفیگ SSHPlus")
local host = m:field(Value, "HOST", "SSH Host")
host.default = readval("HOST")
local user = m:field(Value, "USER", "SSH Username")
user.default = readval("USER")
local port = m:field(Value, "PORT", "SSH Port")
port.default = readval("PORT")
local auth = m:field(ListValue, "AUTH_METHOD", "Auth Method")
auth.default = readval("AUTH_METHOD")
auth:value("password", "Password")
auth:value("key", "Private Key")
local pass = m:field(Value, "PASS", "SSH Password (اگر پسوردی)")
pass.password = true
pass.default = readval("PASS")
local keyfile = m:field(Value, "KEY_FILE", "Private Key File (اگر کلید)")
keyfile.default = readval("KEY_FILE")
function m.handle(self, state, data)
    if state == FORM_VALID then
        local new = {
            "HOST=" .. (data.HOST or ""),
            "USER=" .. (data.USER or ""),
            "PORT=" .. (data.PORT or ""),
            "AUTH_METHOD=" .. (data.AUTH_METHOD or ""),
            "PASS=" .. (data.PASS or ""),
            "KEY_FILE=" .. (data.KEY_FILE or "")
        }
        local f = io.open(conf_path, "w+")
        for _, line in ipairs(new) do f:write(line .. "\n") end
        f:close()
        self.message = "✅ تنظیمات ذخیره شد!"
    end
    return true
end
return m
EOF

# ۵. View statuspage
cat > /usr/lib/lua/luci/view/sshplus_statuspage.htm <<"EOF"
<%+header%>
<style>
.sshplus-title {
  font-size: 3vw;
  font-weight: bold;
  color: #444;
  margin-top: 42px;
  margin-bottom: 32px;
  text-align: center;
  line-height: 1.2;
  letter-spacing: 2px;
}
.sshplus-status-panel {
  max-width: 540px;
  background: #fff;
  margin: 0 auto 32px auto;
  border-radius: 2.2rem;
  padding: 38px 28px 34px 28px;
  box-shadow: 0 2px 16px 0 #aaa4;
  border: 1.2px solid #e2e4eb;
}
.sshplus-row {
  display: flex;
  flex-direction: row;
  justify-content: flex-end;
  align-items: center;
  gap: 16px;
  font-size: 1.5vw;
  margin-bottom: 24px;
  line-height: 2.1;
}
.sshplus-label {
  color: #606266;
  min-width: 120px;
  font-size: 1.21em;
}
.sshplus-status {
  font-weight: bold;
  font-size: 1.39em;
  color: #18cc29;
}
.sshplus-status.disconnected {
  color: #e52d2d;
}
.sshplus-ip {
  font-weight: 600;
  font-size: 1.15em;
  color: #1465ba;
  direction: ltr;
  padding-left: 7px;
  letter-spacing: 1px;
}
.sshplus-uptime {
  font-size: 1.09em;
  color: #009bc9;
  font-weight: 600;
  letter-spacing: 1px;
}
.sshplus-btn {
  background: #ff8080;
  color: white;
  font-size: 2vw;
  border-radius: 20px;
  padding: 21px 48px 20px 48px;
  border: none;
  cursor: pointer;
  font-weight: bold;
  margin-top: 28px;
  margin-bottom: 8px;
  margin-left: auto;
  margin-right: auto;
  display: block;
  transition: background 0.18s, color 0.16s;
  letter-spacing: 1px;
  box-shadow: 0 1px 6px #9992;
}
.sshplus-btn.on {
  background: #38db8b;
  color: #fff;
}
.sshplus-btn i {
  font-size: 1.2em;
  margin-left: 13px;
  vertical-align: middle;
}
@media (max-width: 650px) {
  .sshplus-title { font-size: 6vw;}
  .sshplus-row, .sshplus-btn { font-size: 3.3vw;}
  .sshplus-status-panel { padding: 22px 5vw;}
}
</style>

<div class="sshplus-title">
  وضعیت و کنترل <span style="color:#888">SSHPlus</span>
</div>
<div class="sshplus-status-panel">
  <div class="sshplus-row">
    <span class="sshplus-label">وضعیت سرویس:</span>
    <span id="statusText" class="sshplus-status">...</span>
    <span id="statusIcon" style="font-size:1.2em;margin-right:8px;">...</span>
  </div>
  <div class="sshplus-row">
    <span class="sshplus-label">IP خروجی:</span>
    <span id="ipText" class="sshplus-ip">...</span>
  </div>
  <div class="sshplus-row">
    <span class="sshplus-label">زمان اتصال:</span>
    <span id="uptimeText" class="sshplus-uptime">...</span>
  </div>
  <button class="sshplus-btn" id="mainBtn" onclick="toggle()">
    <i id="mainBtnIcon">⛔</i>
    <span id="mainBtnText">...</span>
  </button>
</div>

<script>
function formatUptime(secs) {
  if (isNaN(secs) || secs < 0) return "-";
  let m = Math.floor(secs / 60);
  let s = secs % 60;
  if (m > 0) return m + " دقیقه و " + s + " ثانیه";
  return s + " ثانیه";
}
function updateStatus() {
  XHR.get('<%=luci.dispatcher.build_url("admin/services/sshplus_status_api")%>', null, function(x, st) {
    let running = st.running, ip = st.ip?.trim() || "N/A", up = st.uptime || 0;
    let statusText = document.getElementById("statusText");
    statusText.innerHTML = running ? "وصل" : "قطع";
    statusText.className = "sshplus-status" + (running ? "" : " disconnected");
    document.getElementById("statusIcon").innerHTML = running ? "✅" : "⛔";
    document.getElementById("ipText").innerText = ip;
    document.getElementById("uptimeText").innerText = running ? formatUptime(up) : "-";
    let btn = document.getElementById("mainBtn");
    let btnIcon = document.getElementById("mainBtnIcon");
    let btnText = document.getElementById("mainBtnText");
    if (running) {
      btn.classList.remove("on");
      btn.style.background = "#ff8080";
      btnIcon.innerText = "⛔";
      btnText.innerText = "قطع کن";
    } else {
      btn.classList.add("on");
      btn.style.background = "#38db8b";
      btnIcon.innerText = "✔️";
      btnText.innerText = "وصل کن";
    }
  });
}
function toggle() {
  XHR.get('<%=luci.dispatcher.build_url("admin/services/sshplus_toggle")%>', null, function() {
    setTimeout(updateStatus, 1200);
  });
}
setInterval(updateStatus, 3000);
updateStatus();
</script>
<%+footer%>
EOF

# ۶. اسکریپت راه‌انداز اصلی
cat > /etc/init.d/sshplus <<"EOF"
#!/bin/sh /etc/rc.common
START=99
STOP=10

start() {
    # قبل از هر استارت، تمام پروسه‌های sshplus و ssh با پورت 8089 رو kill کن
    echo "Stopping all old SSHPlus sessions..."
    screens=$(screen -ls | grep "sshplus" | awk '{print $1}' | sed 's/\..*//')
    if [ -n "$screens" ]; then
        for s in $screens; do
            screen -S "$s" -X quit
        done
    fi
    # کشتن تمام پراسس ssh که روی پورت 8089 هست
    pids=$(netstat -tulnp 2>/dev/null | grep 8089 | awk '{print $7}' | cut -d'/' -f1)
    if [ -n "$pids" ]; then
        for pid in $pids; do
            [ ! -z "$pid" ] && kill $pid 2>/dev/null
        done
    fi

    . /etc/sshplus.conf
    # پارامتر KeepAlive به صورت خودکار اضافه شده (در هر دو حالت)
    if [ "$AUTH_METHOD" = "key" ]; then
        screen -dmS sshplus ssh -i "$KEY_FILE" \
            -o ServerAliveInterval=30 \
            -o ServerAliveCountMax=3 \
            -o StrictHostKeyChecking=no \
            -o UserKnownHostsFile=/dev/null \
            -o Ciphers=chacha20-poly1305@openssh.com \
            -o Compression=no \
            -D 8089 -N -p "$PORT" "$USER@$HOST"
    else
        screen -dmS sshplus sshpass -p "$PASS" ssh \
            -o ServerAliveInterval=30 \
            -o ServerAliveCountMax=3 \
            -o StrictHostKeyChecking=no \
            -o UserKnownHostsFile=/dev/null \
            -o Ciphers=chacha20-poly1305@openssh.com \
            -o Compression=no \
            -D 8089 -N -p "$PORT" "$USER@$HOST"
    fi
    # ذخیره زمان شروع
    date +%s > /tmp/sshplus_start_time
}

stop() {
    screens=$(screen -ls | grep "sshplus" | awk '{print $1}' | sed 's/\..*//')
    if [ -n "$screens" ]; then
        for s in $screens; do
            screen -S "$s" -X quit
        done
        echo "All SSHPlus screen sessions stopped."
    else
        echo "No active SSHPlus screen session found."
    fi
    # کشتن پراسس ssh روی 8089
    pids=$(netstat -tulnp 2>/dev/null | grep 8089 | awk '{print $7}' | cut -d'/' -f1)
    if [ -n "$pids" ]; then
        for pid in $pids; do
            [ ! -z "$pid" ] && kill $pid 2>/dev/null
        done
        echo "SSH processes on port 8089 killed."
    fi
    # حذف فایل زمان شروع
    rm -f /tmp/sshplus_start_time
}
EOF
chmod +x /etc/init.d/sshplus

# ۷. اسکریپت watchdog
cat > /root/sshplus-watchdog.sh <<"EOF"
#!/bin/sh

service="/etc/init.d/sshplus"

# اگر هیچ پروسه‌ی screen با نام sshplus وجود نداشت یا پورت 8089 باز نبود، ریستارت کن
if ! screen -ls | grep -q 'sshplus' || ! netstat -tuln | grep -q ':8089 '; then
    echo "[sshplus-watchdog] SSHPlus tunnel is DOWN, restarting..."
    $service restart
fi
EOF
chmod +x /root/sshplus-watchdog.sh

# ۸. کرون جاب
grep -q "sshplus-watchdog.sh" /etc/crontabs/root 2>/dev/null || \
echo '* * * * * /root/sshplus-watchdog.sh' >> /etc/crontabs/root
/etc/init.d/cron restart

# ۹. فایل کانفیگ اولیه اگر وجود ندارد
[ -f /etc/sshplus.conf ] || echo -e "HOST=\nUSER=\nPORT=\nAUTH_METHOD=password\nPASS=\nKEY_FILE=" > /etc/sshplus.conf

echo
echo "✅ نصب SSHPlus و UI کامل شد!"
echo "از طریق Services > SSHPlus در پنل OpenWrt در دسترس است."
