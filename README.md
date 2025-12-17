# Central Monitoring (Prometheus + Node Exporter + Grafana)

## Yêu cầu
- 1 máy monitoring chạy Docker (Prometheus + Grafana)
- >= 3 máy node (Linux) chạy Node Exporter + script HTTP uptime

## 1) Chạy Monitoring Stack (Prometheus + Grafana)
Trên monitoring server:

1. Copy env:
   cp .env.example .env
   # chỉnh GRAFANA_ADMIN_PASSWORD nếu muốn

2. Chạy stack:
   cd monitoring
   docker compose up -d

3. Kiểm tra:
- Prometheus: http://<MON_IP>:9090
- Grafana:    http://<MON_IP>:3000 (user: admin, pass: theo .env)

4. Thêm node targets:
- Sửa file: monitoring/prometheus/targets/nodes.json
- Sau đó reload Prometheus:
  curl -X POST http://<MON_IP>:9090/-/reload
  (hoặc restart container prometheus)

## 2) Cài Node Exporter + HTTP uptime metric trên mỗi node
Trên từng node (Linux):

1. Tạo thư mục textfile collector:
   sudo mkdir -p /var/lib/node_exporter/textfile_collector

2. Chạy node-exporter bằng docker compose:
   cd node
   sudo docker compose -f docker-compose.node-exporter.yml up -d

3. Cài script uptime:
   sudo cp textfile_collector/check_webapp.sh /usr/local/bin/check_webapp.sh
   sudo chmod +x /usr/local/bin/check_webapp.sh

4. (Khuyến nghị) Tạo file cấu hình URL healthcheck:
   echo 'WEBAPP_URL="http://127.0.0.1:8080/health"' | sudo tee /etc/default/webapp-check

5. Cài systemd timer chạy mỗi 5 giây:
   sudo cp systemd/webapp-check.service /etc/systemd/system/webapp-check.service
   sudo cp systemd/webapp-check.timer /etc/systemd/system/webapp-check.timer
   sudo systemctl daemon-reload
   sudo systemctl enable --now webapp-check.timer

6. Kiểm tra metric:
   curl http://127.0.0.1:9100/metrics | grep webapp_up

## 3) Grafana Dashboard & Alert
- Dashboard được provision sẵn: "Central Monitoring"
- Refresh: 5s

Alert (tạo nhanh trong Grafana UI):
- Query: webapp_up
- Condition: IS BELOW 1
- For: 1m
- Contact points: Email + Teams (Incoming Webhook)

Lưu ý: Email cần cấu hình SMTP trong Grafana (qua env hoặc UI).
