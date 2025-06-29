#!/bin/sh

set -e

# ۱. دانلود و ساخت فایل‌های LuCI
mkdir -p /usr/lib/lua/luci/controller
mkdir -p /usr/lib/lua/luci/model/cbi
mkdir -p /usr/lib/lua/luci/view

cat > /usr/lib/lua/luci/controller/sshplus.lua <<'EOF'
module("luci.controller.sshplus", package.seeall)
function index()
    if not nixio.fs.access("/etc/init.d/sshplus") then
        return
    end
    entry({"admin", "services", "sshplus"}, form("sshplus"), "SSHPlus", 90).dependent = true
    entry({"admin", "services", "sshplus_statuspage"}, template("sshplus_statuspage"), "وضعیت SSHPlus", 91).dependent = true
    entry({"admin", "services", "sshplus_status_api"}, call("action_status")).leaf = true
    entry({"admin", "services", "sshplus_toggle"}, call("action_toggle")).leaf = true
end

function action_status()
    local running = (os.execute("/etc/init.d/sshplus status >/dev/null 2>&1") == 0)
    local ip = luci.sys.exec("curl --socks5 127.0.0.1:8089 -s http://ifconfig.me || echo N/A")
    local uptime = 0
    if nixio.fs.access("/tmp/sshplus_start_time") then
        local f = io.open("/tmp/sshplus_start_time", "r")
        local start = tonumber(f:read("*a") or "0")
        f:close()
        uptime = os.time() - start
    end
    luci.http.prepare_content("application/json")
    luci.http.write_json({running = running, ip = ip, uptime = uptime})
end

function action_toggle()
    local running = (os.execute("/etc/init.d/sshplus status >/dev/null 2>&1") == 0)
    if running then
        os.execute("/etc/init.d/sshplus stop")
    else
        os.execute("/etc/init.d/sshplus start")
    end
    luci.http.status(200, "OK")
end
EOF

# مدل CBI اصلی
cat > /usr/lib/lua/luci/model/cbi/sshplus.lua <<'EOF'
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
local host = m:field(Value, "HOST", "SSH Host"); host.default = readval("HOST")
local user = m:field(Value, "USER", "SSH Username"); user.default = readval("USER")
local port = m:field(Value, "PORT", "SSH Port"); port.default = readval("PORT")
local auth = m:field(ListValue, "AUTH_METHOD", "Auth Method")
auth.default = readval("AUTH_METHOD"); auth:value("password", "Password"); auth:value("key", "Private Key")
local pass = m:field(Value, "PASS", "SSH Password (اگر پسوردی)"); pass.password = true; pass.default = readval("PASS")
local keyfile = m:field(Value, "KEY_FILE", "Private Key File (اگر کلید)"); keyfile.default = readval("KEY_FILE")
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
        self.message = "✅ تنظیمات ذخیره شد. انتقال به صفحه وضعیت..."
        luci.http.header("Refresh", "1.2; url=" .. luci.dispatcher.build_url("admin/services/sshplus_statuspage"))
    end
    return true
end
return m
EOF

# مدل وضعیت (اختیاری، اگر می‌خوای فقط نمای ساده داشته باشی حذفش کن)
cat > /usr/lib/lua/luci/model/cbi/sshplus_statuspage.lua <<'EOF'
return {}
EOF

# نمای وضعیت پیشرفته (HTML و JS)
cat > /usr/lib/lua/luci/view/sshplus_statuspage.htm <<'EOF'
<%+header%>
<style>
body, .cbi-section, .main { background: #fafbfc!important;}
.sshplus-title { font-size: 2.6vw; font-weight: bold; color: #bbb; margin: 32px 0 16px 0; text-align: center;}
.sshplus-status-panel { max-width: 480px; background: #e5e5e5; margin: 0 auto 32px auto; border-radius: 28px; padding: 36px 18px 30px 18px; box-shadow: 0 2px 10px #2223;}
.sshplus-row { display: flex; flex-direction: row; justify-content: flex-end; align-items: center; gap: 14px; font-size: 1.5vw; margin-bottom: 20px; line-height: 1.8;}
.sshplus-label { color: #888; min-width: 120px; font-size: 1.1em;}
.sshplus-status { font-weight: bold; font-size: 1.25em; color: #18ea27;}
.sshplus-status.disconnected { color: #f33;}
.sshplus-ip { font-weight: bold; font-size: 1.1em; color: #999; direction: ltr; padding-left: 8px;}
.sshplus-uptime { font-size: 1em; color: #2294d6;}
.sshplus-btn { background: #ff8080; color: white; font-size: 1.7vw; border-radius: 20px; padding: 18px 44px; border: none; cursor: pointer; font-weight: bold; margin-top: 18px; margin-bottom: 4px; margin-left: auto; margin-right: auto; display: block; transition: background 0.18s;}
.sshplus-btn.on { background: #38db8b;}
.sshplus-btn i { font-size: 1.2em; margin-left: 12px; vertical-align: middle;}
@media (max-width: 650px) {.sshplus-title { font-size: 5vw;} .sshplus-row, .sshplus-btn { font-size: 3vw;} .sshplus-status-panel { padding: 16px 3vw;}}
</style>
<div class="sshplus-title">
  وضعیت و کنترل <span style="color:#aaa">SSHPlus</span>
</div>
<div class="sshplus-status-panel">
  <div class="sshplus-row"><span class="sshplus-label">وضعیت سرویس:</span><span id="statusText" class="sshplus-status">...</span><span id="statusIcon" style="font-size:1.2em;margin-right:8px;">...</span></div>
  <div class="sshplus-row"><span class="sshplus-label">IP خروجی:</span><span id="ipText" class="sshplus-ip">...</span></div>
  <div class="sshplus-row"><span class="sshplus-label">زمان اتصال:</span><span id="uptimeText" class="sshplus-uptime">...</span></div>
  <button class="sshplus-btn" id="mainBtn" onclick="toggle()"><i id="mainBtnIcon">⛔</i><span id="mainBtnText">...</span></button>
</div>
<script>
function formatUptime(secs) {if (isNaN(secs) || secs < 0) return "-";let m = Math.floor(secs / 60);let s = secs % 60; if (m > 0) return m + " دقیقه و " + s + " ثانیه"; return s + " ثانیه";}
function updateStatus() {XHR.get('<%=luci.dispatcher.build_url("admin/services/sshplus_status_api")%>', null, function(x, st) {let running = st.running, ip = st.ip?.trim() || "N/A", up = st.uptime || 0;let statusText = document.getElementById("statusText");statusText.innerHTML = running ? "وصل" : "قطع";statusText.className = "sshplus-status" + (running ? "" : " disconnected");document.getElementById("statusIcon").innerHTML = running ? "✅" : "⛔";document.getElementById("ipText").innerText = ip;document.getElementById("uptimeText").innerText = running ? formatUptime(up) : "-";let btn = document.getElementById("mainBtn");let btnIcon = document.getElementById("mainBtnIcon");let btnText = document.getElementById("mainBtnText");if (running) {btn.classList.remove("on");btn.style.background = "#ff8080";btnIcon.innerText = "⛔";btnText.innerText = "قطع کن";} else {btn.classList.add("on");btn.style.background = "#38db8b";btnIcon.innerText = "✔️";btnText.innerText = "وصل کن";}});}
function toggle() {XHR.get('<%=luci.dispatcher.build_url("admin/services/sshplus_toggle")%>', null, function() {setTimeout(updateStatus, 1200);});}
setInterval(updateStatus, 3000);updateStatus();
</script>
<%+footer%>
EOF

# نمای ساده (فقط برای تست)
cat > /usr/lib/lua/luci/view/sshplus.lua <<'EOF'
<%+header%>
<h2>SSHPlus: مدیریت و تنظیم SSH Tunnel</h2>
<div>لطفاً از تب سرویس "SSHPlus" برای مدیریت استفاده کنید.</div>
<%+footer%>
EOF

# ۲. اسکریپت راه‌انداز اصلی (init.d)
cat > /etc/init.d/sshplus <<'EOF'
#!/bin/sh /etc/rc.common
START=99
STOP=10

start() {
    # Kill old screen/sshplus
    screens=$(screen -ls | grep "sshplus" | awk '{print $1}' | sed 's/\..*//')
    if [ -n "$screens" ]; then
        for s in $screens; do
            screen -S "$s" -X quit
        done
    fi
    # Kill old ssh on 8089
    pids=$(netstat -tulnp 2>/dev/null | grep 8089 | awk '{print $7}' | cut -d'/' -f1)
    if [ -n "$pids" ]; then
        for pid in $pids; do
            [ ! -z "$pid" ] && kill $pid 2>/dev/null
        done
    fi
    . /etc/sshplus.conf
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
    date +%s > /tmp/sshplus_start_time
}

stop() {
    screens=$(screen -ls | grep "sshplus" | awk '{print $1}' | sed 's/\..*//')
    if [ -n "$screens" ]; then
        for s in $screens; do
            screen -S "$s" -X quit
        done
    fi
    pids=$(netstat -tulnp 2>/dev/null | grep 8089 | awk '{print $7}' | cut -d'/' -f1)
    if [ -n "$pids" ]; then
        for pid in $pids; do
            [ ! -z "$pid" ] && kill $pid 2>/dev/null
        done
    fi
    rm -f /tmp/sshplus_start_time
}
EOF
chmod +x /etc/init.d/sshplus

# ۳. Watchdog برای ریکاوری خودکار
cat > /root/sshplus-watchdog.sh <<'EOF'
#!/bin/sh
if ! /etc/init.d/sshplus status | grep -q running; then
  /etc/init.d/sshplus stop
  sleep 1
  /etc/init.d/sshplus start
fi
EOF
chmod +x /root/sshplus-watchdog.sh

# ۴. افزودن کرون‌جاب برای Watchdog
grep -q "sshplus-watchdog.sh" /etc/crontabs/root 2>/dev/null || \
echo '*/1 * * * * /root/sshplus-watchdog.sh' >> /etc/crontabs/root

/etc/init.d/cron restart

echo
echo "✅ نصب و راه‌اندازی SSHPlus کامل شد!"
echo "از منوی Services > SSHPlus در LuCI قابل دسترس است."
