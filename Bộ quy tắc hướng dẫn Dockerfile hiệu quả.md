# Bộ quy tắc hướng dẫn Dockerfile hiệu quả - đúng luật

Dưới đây là bộ checklist Dockerfile Contest 2025 bao gồm ba lớp: RÀNG BUỘC (bắt buộc tuân thủ), CHO PHÉP (để sáng tạo), và CHẤM ĐIỂM (tiêu chí & trọng số). 

Mục tiêu: khuyến khích bảo mật – nhẹ – build nhanh – chạy ổn định và vẫn có nhiều cách sáng tạo mà vẫn "Đúng luật".

## 1) RÀNG BUỘC (bắt buộc)

* Tên file nộp: Viết Dockerfile như thông thường nhưng khi nộp sẽ thêm đuôi `.txt` (ví dụ: `Dockerfile.txt`).
* Không thay đổi source code dự án: không sửa/xóa/thêm file trong source gốc; không chỉnh config runtime của app trong repo.
* Build phải thành công trên Linux (amd64) với Docker + BuildKit mặc định.
* Context build là thư mục gốc dự án (như BTC cung cấp), chạy lệnh mẫu:
  `DOCKER_BUILDKIT=1 docker build -t app:contest -f Dockerfile.txt .`
* Runtime phải start được và phục vụ đúng “điểm kiểm” BTC (ví dụ HTTP `/health` hay `/` hoặc port/command được BTC công bố), dừng được bằng SIGTERM trong ≤ 10s.
* Không hardcode secrets/token/keys trong Dockerfile hoặc layer. Không `ADD`/`curl` từ URL bên ngoài trừ khi kèm checksum/GPG verify rõ ràng.
* Có `HEALTHCHECK` hợp lý (nhanh, rẻ). Nếu app là CLI/worker, nêu rõ lý do và cách BTC kiểm chứng “sống”.
* Không sửa host network/kernel params; không yêu cầu privileged/capabilities đặc biệt khi chạy.
* Không vi phạm bản quyền/chính sách upstream (package repos chính thức, license rõ ràng).

## 2) CHO PHÉP (để sáng tạo thay vì “đồng phục”)

* Được chọn base image tùy ý (alpine/-slim/distroless/chainguard/ubi…) miễn chạy đúng chức năng.
* Được multi-stage không giới hạn số stage; được tận dụng cache mount BuildKit (apt/pip/npm/pnpm/go).
* Khuyến khích những base image tự build để thể hiện tối đa kỹ năng chuyên môn. 
* Được chọn chiến lược COPY thông minh: **không bắt buộc copy toàn bộ repo**. Bạn có thể:

  * COPY lockfile/manifest trước (để cache deps),
  * chỉ COPY đúng thư mục/binary cần thiết,
  * tránh copy test/docs/.git để ảnh nhẹ hơn.
    (Đây là “cửa” để tối ưu dù không đụng vào source gốc.)
* Được pin version/digest base image; được bật multi-arch build (x86_64/arm64) nếu muốn lấy điểm thưởng.
* Được thêm OCI labels (source, version, revision, licenses, created…); được sinh SBOM và/hoặc scan CVE (điểm thưởng).
* Được tối ưu runtime: read-only rootfs, `--cap-drop=ALL`, thêm user/group cụ thể (nhưng phần này chủ yếu ghi trong README hướng dẫn chạy).
* Được tối ưu khởi động (Java CDS, Go static, Python wheels…), miễn không sửa code app.
* Được thêm `EXPOSE` hợp lý và biến môi trường (ENV) cần thiết (không sửa file cấu hình trong repo gốc).

## 3) NHỮNG ĐIỀU BỊ CẤM (loại ngay)

* Thêm/sửa/xóa bất kỳ file nào của source gốc; tạo patch/commit mới vào repo.
* Lộ secrets trong Dockerfile, trong history của image, hoặc tải script “lạ” từ internet mà không verify.
* Chạy container với root hoặc yêu cầu `--privileged`/mở capabilities rộng mà không có lý do bắt buộc.
* Embed cả compiler và toolchain nặng trong ảnh runtime (trừ khi chứng minh là bắt buộc để chạy).

## 4) ĐẦU RA NỘP BÀI

* `Dockerfile.txt`.
* [Không bắt buộc] Một đoạn “Hướng dẫn chạy” 5–10 dòng (dán kèm trong form nộp) gồm:

  * lệnh build BTC sẽ chạy;
  * lệnh run mẫu (port, ENV cần tối thiểu);
  * endpoint/điều kiện pass health;
  * nếu cần network outbound nội bộ (ví dụ call DB giả lập do BTC dựng), hãy nêu rõ.
* Tùy chọn điểm thưởng:

  * Image size (từ `docker image ls`) và `docker history --no-trunc` (để BTC xác minh layer tối ưu).
  * SBOM (Syft) + scan report (Trivy/Grype) không lỗi High/Critical.
  * multi-arch manifest (buildx).

## 5) MÔI TRƯỜNG KIỂM THỬ CHUẨN CỦA BTC (tham khảo)

* OS: Linux x86_64, Docker 26+/BuildKit on, buildx.
* Tài nguyên build (ví dụ): 2 vCPU, 4GB RAM, timeout build 8 phút.
* Runtime limit: 1 vCPU, 512MB RAM (điểm hiệu năng xét trong khung này).
* Không có proxy internet đặc biệt; outbound access cho package manager ở mức bình thường.
* BTC chạy đúng lệnh build/run do thí sinh cung cấp; mọi trick phụ thuộc máy riêng sẽ không được tính.

## 6) THANG ĐIỂM ĐỀ XUẤT (100 điểm)

* Bảo mật (35đ)
* Nhẹ & tối ưu layer (25đ)
* Tốc độ build & cache (15đ)
* Đúng chức năng & ổn định (15đ)
* Tài liệu ngắn gọn – rõ (10đ)

**Điểm thưởng (tối đa +10):** multi-arch (+3), SBOM + scan sạch High/Critical (+5), ký image/provenance (Cosign/SLSA) (+2).

## 7) CÁC TÌNH HUỐNG HAY GÂY NHẦM LẪN (FAQ ngắn)

* “Không thay đổi source” có nghĩa là gì?
  → Không sửa/xóa/thêm file trong repo gốc. Bạn vẫn được **chọn lọc COPY** trong Dockerfile; đó là nơi tối ưu chính.
* Có được tải thêm package hệ điều hành?
  → Được, nếu là repo chính thống và bạn dọn sạch cache, pin phiên bản hợp lý. Tải file “lạ” từ internet phải có checksum/GPG verify.
* App không có HTTP health thì HEALTHCHECK làm gì?
  → Dùng lệnh rẻ kiểm tra điều kiện sống phù hợp (ví dụ check process/binary trả mã 0, hoặc TCP port open), giải thích trong hướng dẫn chạy.
* Có phải bắt buộc Alpine?
  → Không. Chọn base phù hợp chức năng + bảo trì + bảo mật; trọng số chấm tính **kết quả**.

## 8) BTC KIỂM THỬ TỰ ĐỘNG (gợi ý pipeline)

* Build: `docker build -t app:contest -f Dockerfile.txt .`
* Verify: `docker run --rm -d --name app -p 8080:8080 app:contest`
* Health: retry HTTP `GET /health` (hoặc lệnh do BTC chỉ định) trong 60s.
* Stop: `docker stop app` đo thời gian thoát; fail nếu >10s.
* Đo size: `docker image ls` + `docker history`.
* (Tuỳ chọn) Scan: Trivy/Grype; SBOM: Syft.