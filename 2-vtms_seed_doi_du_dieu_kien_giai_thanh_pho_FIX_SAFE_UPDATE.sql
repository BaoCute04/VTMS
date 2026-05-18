-- =========================================================
-- VTMS SEED: DOI DU DIEU KIEN THAM GIA GIAI CAP TINH/THANH
-- Database: vtms
-- Run after:
--   1) vtms_full_rebuild.sql
--   2) vtms_migration_add_tu_cach_doi_v2_strict_FIX.sql
-- Purpose:
--   FIX v3: tat SQL_SAFE_UPDATES trong phien chay seed de tranh loi Workbench 1175.
--   FIX v2: dat ngaytao cua bangxephang <= ngaycongbo de khop chk_bxh_ngaycongbo.
--   Bo sung du lieu gia dinh: cac doi dai dien quan/huyen du dieu kien
--   tham gia Giai bong chuyen TP.HCM 2026 vi la doi vo dich giai chinh thuc
--   cua quan/huyen tuong ung.
-- =========================================================

USE vtms;
SET FOREIGN_KEY_CHECKS = 1;
SET SQL_MODE = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
SET @VTMS_OLD_SQL_SAFE_UPDATES := @@SQL_SAFE_UPDATES;
SET SQL_SAFE_UPDATES = 0;
START TRANSACTION;

-- =========================================================
-- 1. Bo sung khu vuc xa/phuong con cho cac quan/huyen dang thieu du lieu mau
-- =========================================================
INSERT INTO khuvuc(idkhuvuc, makhuvuc, tenkhuvuc, capkhuvuc, idkhuvuccha, mota, trangthai)
VALUES
(1001,'P_BEN_NGHE_Q1','Phuong Ben Nghe - Quan 1','XA_PHUONG',11,'Xa/phuong thuoc Quan 1','HOAT_DONG'),
(1002,'P_BEN_THANH_Q1','Phuong Ben Thanh - Quan 1','XA_PHUONG',11,'Xa/phuong thuoc Quan 1','HOAT_DONG'),
(1012,'P_TCH_Q12','Phuong Tan Chanh Hiep - Quan 12','XA_PHUONG',12,'Xa/phuong thuoc Quan 12','HOAT_DONG'),
(1013,'P_HT_Q12','Phuong Hiep Thanh - Quan 12','XA_PHUONG',12,'Xa/phuong thuoc Quan 12','HOAT_DONG'),
(1026,'P_26_BT','Phuong 26 - Binh Thanh','XA_PHUONG',13,'Xa/phuong thuoc Binh Thanh','HOAT_DONG')
ON DUPLICATE KEY UPDATE
    tenkhuvuc = VALUES(tenkhuvuc),
    capkhuvuc = VALUES(capkhuvuc),
    idkhuvuccha = VALUES(idkhuvuccha),
    mota = VALUES(mota),
    trangthai = VALUES(trangthai),
    ngaycapnhat = NOW();

-- =========================================================
-- 2. Bo sung BTC cap quan/huyen cho Quan 1, Quan 12, Binh Thanh
--    Ghi chu: Gò Vấp da co BTC id = 3 trong seed goc.
-- =========================================================
INSERT INTO taikhoan(idtaikhoan, username, password, email, sodienthoai, idrole, trangthai)
VALUES
(101,'btc_q1','hashed_btc','btc.q1@vtms.vn','0900000101',2,'HOAT_DONG'),
(102,'btc_q12','hashed_btc','btc.q12@vtms.vn','0900000102',2,'HOAT_DONG'),
(103,'btc_binhthanh','hashed_btc','btc.binhthanh@vtms.vn','0900000103',2,'HOAT_DONG')
ON DUPLICATE KEY UPDATE
    password = VALUES(password),
    email = VALUES(email),
    sodienthoai = VALUES(sodienthoai),
    idrole = VALUES(idrole),
    trangthai = VALUES(trangthai),
    ngaycapnhat = NOW();

INSERT INTO nguoidung(idnguoidung, idtaikhoan, hodem, ten, gioitinh, ngaysinh, quequan, diachi, cccd)
VALUES
(101,101,'Nguyen','BTC Quan 1','NAM','1985-01-01','TP.HCM','Quan 1','001000000101'),
(102,102,'Nguyen','BTC Quan 12','NAM','1985-01-02','TP.HCM','Quan 12','001000000102'),
(103,103,'Nguyen','BTC Binh Thanh','NU','1985-01-03','TP.HCM','Binh Thanh','001000000103')
ON DUPLICATE KEY UPDATE
    hodem = VALUES(hodem),
    ten = VALUES(ten),
    gioitinh = VALUES(gioitinh),
    ngaysinh = VALUES(ngaysinh),
    quequan = VALUES(quequan),
    diachi = VALUES(diachi),
    cccd = VALUES(cccd),
    ngaycapnhat = NOW();

INSERT INTO bantochuc(idbantochuc, idnguoidung, idcapbantochuc, idkhuvucquanly, idbantochuccha, donvi, chucvu, trangthai)
VALUES
(101,101,3,11,2,'BTC Bóng chuyền Quận 1','BTC cấp quận/huyện','HOAT_DONG'),
(102,102,3,12,2,'BTC Bóng chuyền Quận 12','BTC cấp quận/huyện','HOAT_DONG'),
(103,103,3,13,2,'BTC Bóng chuyền Bình Thạnh','BTC cấp quận/huyện','HOAT_DONG')
ON DUPLICATE KEY UPDATE
    idcapbantochuc = VALUES(idcapbantochuc),
    idkhuvucquanly = VALUES(idkhuvucquanly),
    idbantochuccha = VALUES(idbantochuccha),
    donvi = VALUES(donvi),
    chucvu = VALUES(chucvu),
    trangthai = VALUES(trangthai);

-- =========================================================
-- 3. Bo sung doi dai dien quan/huyen con thieu cho Giai TP.HCM
--    Doi 5,6 da co san: Go Vap Spikers, Quan 1 Servers.
-- =========================================================
INSERT INTO doibong(iddoibong, tendoibong, idkhuvucdaidien, diaphuong, mota, idhuanluyenvien, diem_xep_hang, trangthai)
VALUES
(11,'Quận 12 Strikers',12,'Quận 12','Đội đại diện Quận 12, giả định vô địch giải chính thức cấp quận/huyện.',3,66,'HOAT_DONG'),
(12,'Bình Thạnh Warriors',13,'Bình Thạnh','Đội đại diện Bình Thạnh, giả định vô địch giải chính thức cấp quận/huyện.',4,64,'HOAT_DONG')
ON DUPLICATE KEY UPDATE
    idkhuvucdaidien = VALUES(idkhuvucdaidien),
    diaphuong = VALUES(diaphuong),
    mota = VALUES(mota),
    idhuanluyenvien = VALUES(idhuanluyenvien),
    diem_xep_hang = VALUES(diem_xep_hang),
    trangthai = VALUES(trangthai),
    ngaycapnhat = NOW();

-- =========================================================
-- 4. Tao cac giai chinh thuc cap quan/huyen lam nguon thanh tich
-- =========================================================
INSERT INTO giaidau(idgiaidau, tengiaidau, mota, idcapgiaidau, idkhuvucphamvi, idbantochuc, idluat,
                    thoigianbatdau, thoigianketthuc, quymo, tinhchat, trangthai, trangthaidangky,
                    trangthaithietlap, ghichu_diadiem)
VALUES
(101,'Giải bóng chuyền Quận Gò Vấp 2026','Giải chính thức cấp quận/huyện dùng làm nguồn xét tư cách lên giải TP.HCM.',3,10,3,2,'2026-04-01','2026-04-07',4,'CHINH_THUC','DA_KET_THUC','DA_DONG','DA_CONG_BO_LICH','Địa điểm từng trận được chọn khi lập lịch'),
(102,'Giải bóng chuyền Quận 1 2026','Giải chính thức cấp quận/huyện dùng làm nguồn xét tư cách lên giải TP.HCM.',3,11,101,2,'2026-04-01','2026-04-07',4,'CHINH_THUC','DA_KET_THUC','DA_DONG','DA_CONG_BO_LICH','Địa điểm từng trận được chọn khi lập lịch'),
(103,'Giải bóng chuyền Quận 12 2026','Giải chính thức cấp quận/huyện dùng làm nguồn xét tư cách lên giải TP.HCM.',3,12,102,2,'2026-04-01','2026-04-07',4,'CHINH_THUC','DA_KET_THUC','DA_DONG','DA_CONG_BO_LICH','Địa điểm từng trận được chọn khi lập lịch'),
(104,'Giải bóng chuyền Bình Thạnh 2026','Giải chính thức cấp quận/huyện dùng làm nguồn xét tư cách lên giải TP.HCM.',3,13,103,2,'2026-04-01','2026-04-07',4,'CHINH_THUC','DA_KET_THUC','DA_DONG','DA_CONG_BO_LICH','Địa điểm từng trận được chọn khi lập lịch')
ON DUPLICATE KEY UPDATE
    mota = VALUES(mota),
    idcapgiaidau = VALUES(idcapgiaidau),
    idkhuvucphamvi = VALUES(idkhuvucphamvi),
    idbantochuc = VALUES(idbantochuc),
    idluat = VALUES(idluat),
    thoigianbatdau = VALUES(thoigianbatdau),
    thoigianketthuc = VALUES(thoigianketthuc),
    quymo = VALUES(quymo),
    tinhchat = VALUES(tinhchat),
    trangthai = VALUES(trangthai),
    trangthaidangky = VALUES(trangthaidangky),
    trangthaithietlap = VALUES(trangthaithietlap),
    ghichu_diadiem = VALUES(ghichu_diadiem),
    ngaycapnhat = NOW();

INSERT INTO dieulegiaidau(iddieule, idgiaidau, tieude, noidung, so_doi_toi_thieu, so_doi_toi_da,
                          so_vdv_toi_thieu_moi_doi, so_vdv_toi_da_moi_doi,
                          thoi_gian_mo_dang_ky, thoi_gian_dong_dang_ky,
                          cho_phep_dang_ky_tu_do, yeu_cau_duyet_dang_ky,
                          quy_dinh_bo_cuoc, quy_dinh_khieu_nai)
VALUES
(101,101,'Điều lệ Giải Quận Gò Vấp 2026','Đội vô địch được ghi nhận thành tích để xét tư cách tham gia giải TP.HCM.',2,8,6,12,'2026-03-01 08:00:00','2026-03-20 17:00:00',1,1,'Đội bỏ cuộc xử thua 0-2','Khiếu nại trong vòng 24 giờ'),
(102,102,'Điều lệ Giải Quận 1 2026','Đội vô địch được ghi nhận thành tích để xét tư cách tham gia giải TP.HCM.',2,8,6,12,'2026-03-01 08:00:00','2026-03-20 17:00:00',1,1,'Đội bỏ cuộc xử thua 0-2','Khiếu nại trong vòng 24 giờ'),
(103,103,'Điều lệ Giải Quận 12 2026','Đội vô địch được ghi nhận thành tích để xét tư cách tham gia giải TP.HCM.',2,8,6,12,'2026-03-01 08:00:00','2026-03-20 17:00:00',1,1,'Đội bỏ cuộc xử thua 0-2','Khiếu nại trong vòng 24 giờ'),
(104,104,'Điều lệ Giải Bình Thạnh 2026','Đội vô địch được ghi nhận thành tích để xét tư cách tham gia giải TP.HCM.',2,8,6,12,'2026-03-01 08:00:00','2026-03-20 17:00:00',1,1,'Đội bỏ cuộc xử thua 0-2','Khiếu nại trong vòng 24 giờ')
ON DUPLICATE KEY UPDATE
    tieude = VALUES(tieude),
    noidung = VALUES(noidung),
    so_doi_toi_thieu = VALUES(so_doi_toi_thieu),
    so_doi_toi_da = VALUES(so_doi_toi_da),
    thoi_gian_mo_dang_ky = VALUES(thoi_gian_mo_dang_ky),
    thoi_gian_dong_dang_ky = VALUES(thoi_gian_dong_dang_ky),
    cho_phep_dang_ky_tu_do = VALUES(cho_phep_dang_ky_tu_do),
    yeu_cau_duyet_dang_ky = VALUES(yeu_cau_duyet_dang_ky);

INSERT INTO thethucgiaidau(idthethuc, idgiaidau, tenthethuc, tong_so_vong, co_vong_diem, co_vong_loai,
                           co_tranh_hang_ba, cach_xep_mac_dinh, seed_source_mac_dinh, mota, trangthai)
VALUES
(101,101,'Vòng điểm một lượt cấp quận/huyện',1,1,0,0,'RANDOM','KHONG_AP_DUNG','Mẫu thể thức nguồn để ghi nhận vô địch quận/huyện.','DA_XAC_NHAN'),
(102,102,'Vòng điểm một lượt cấp quận/huyện',1,1,0,0,'RANDOM','KHONG_AP_DUNG','Mẫu thể thức nguồn để ghi nhận vô địch quận/huyện.','DA_XAC_NHAN'),
(103,103,'Vòng điểm một lượt cấp quận/huyện',1,1,0,0,'RANDOM','KHONG_AP_DUNG','Mẫu thể thức nguồn để ghi nhận vô địch quận/huyện.','DA_XAC_NHAN'),
(104,104,'Vòng điểm một lượt cấp quận/huyện',1,1,0,0,'RANDOM','KHONG_AP_DUNG','Mẫu thể thức nguồn để ghi nhận vô địch quận/huyện.','DA_XAC_NHAN')
ON DUPLICATE KEY UPDATE
    tenthethuc = VALUES(tenthethuc),
    tong_so_vong = VALUES(tong_so_vong),
    co_vong_diem = VALUES(co_vong_diem),
    co_vong_loai = VALUES(co_vong_loai),
    co_tranh_hang_ba = VALUES(co_tranh_hang_ba),
    cach_xep_mac_dinh = VALUES(cach_xep_mac_dinh),
    seed_source_mac_dinh = VALUES(seed_source_mac_dinh),
    mota = VALUES(mota),
    trangthai = VALUES(trangthai);

INSERT INTO quytacchondoi(idquytac, idgiaidau, chedochondoi, capdoituongthamgia, soluongdoitoida, mota, trangthai)
VALUES
(101,101,'DANG_KY_THU_CONG','XA_PHUONG',8,'Xã/phường đăng ký, BTC quận/huyện duyệt.', 'HOAT_DONG'),
(102,102,'DANG_KY_THU_CONG','XA_PHUONG',8,'Xã/phường đăng ký, BTC quận/huyện duyệt.', 'HOAT_DONG'),
(103,103,'DANG_KY_THU_CONG','XA_PHUONG',8,'Xã/phường đăng ký, BTC quận/huyện duyệt.', 'HOAT_DONG'),
(104,104,'DANG_KY_THU_CONG','XA_PHUONG',8,'Xã/phường đăng ký, BTC quận/huyện duyệt.', 'HOAT_DONG')
ON DUPLICATE KEY UPDATE
    chedochondoi = VALUES(chedochondoi),
    capdoituongthamgia = VALUES(capdoituongthamgia),
    soluongdoitoida = VALUES(soluongdoitoida),
    mota = VALUES(mota),
    trangthai = VALUES(trangthai);

-- =========================================================
-- 5. Tao BXH chung cuoc cho cac giai quan/huyen va ghi nhan doi vo dich
--    Luu y: du lieu mau nay ghi nhan doi dai dien quan/huyen la doi vo dich
--    de backend co the xet tu cach len giai cap tinh/thanh.
-- =========================================================
INSERT INTO bangxephang(idbangxephang, idgiaidau, idvongdau, idbangdau, tenbangxephang, phamvi, trangthai, ngaytao, ngaycongbo)
VALUES
(101,101,NULL,NULL,'Bảng xếp hạng chung cuộc Quận Gò Vấp 2026','TOAN_GIAI','DA_CONG_BO','2026-04-07 17:00:00','2026-04-07 18:00:00'),
(102,102,NULL,NULL,'Bảng xếp hạng chung cuộc Quận 1 2026','TOAN_GIAI','DA_CONG_BO','2026-04-07 17:00:00','2026-04-07 18:00:00'),
(103,103,NULL,NULL,'Bảng xếp hạng chung cuộc Quận 12 2026','TOAN_GIAI','DA_CONG_BO','2026-04-07 17:00:00','2026-04-07 18:00:00'),
(104,104,NULL,NULL,'Bảng xếp hạng chung cuộc Bình Thạnh 2026','TOAN_GIAI','DA_CONG_BO','2026-04-07 17:00:00','2026-04-07 18:00:00')
ON DUPLICATE KEY UPDATE
    tenbangxephang = VALUES(tenbangxephang),
    phamvi = VALUES(phamvi),
    trangthai = VALUES(trangthai),
    ngaytao = VALUES(ngaytao),
    ngaycongbo = VALUES(ngaycongbo);

INSERT INTO chitietbangxephang(idchitietbxh, idbangxephang, iddoibong, hang, sotran, thang, thua, sosetthang, sosetthua, diem)
VALUES
(101,101,5,1,3,3,0,6,1,9),
(102,102,6,1,3,3,0,6,2,9),
(103,103,11,1,3,3,0,6,2,9),
(104,104,12,1,3,3,0,6,1,9)
ON DUPLICATE KEY UPDATE
    iddoibong = VALUES(iddoibong),
    hang = VALUES(hang),
    sotran = VALUES(sotran),
    thang = VALUES(thang),
    thua = VALUES(thua),
    sosetthang = VALUES(sosetthang),
    sosetthua = VALUES(sosetthua),
    diem = VALUES(diem);

INSERT INTO thanhtichdoibong(
    iddoibong, idgiaidau, idvongdau, idbangxephang, idchitietbxh,
    idcapgiaidau, idkhuvuc, mua_giai, hang_dat_duoc, danhhieu,
    ngay_cong_nhan, nguon_ghi_nhan, ghi_chu, trangthai
)
VALUES
(5,101,NULL,101,101,3,10,2026,1,'VO_DICH','2026-04-07','BANG_XEP_HANG','Vô địch giải chính thức cấp quận/huyện Gò Vấp 2026.', 'HOP_LE'),
(6,102,NULL,102,102,3,11,2026,1,'VO_DICH','2026-04-07','BANG_XEP_HANG','Vô địch giải chính thức cấp quận/huyện Quận 1 2026.', 'HOP_LE'),
(11,103,NULL,103,103,3,12,2026,1,'VO_DICH','2026-04-07','BANG_XEP_HANG','Vô địch giải chính thức cấp quận/huyện Quận 12 2026.', 'HOP_LE'),
(12,104,NULL,104,104,3,13,2026,1,'VO_DICH','2026-04-07','BANG_XEP_HANG','Vô địch giải chính thức cấp quận/huyện Bình Thạnh 2026.', 'HOP_LE')
ON DUPLICATE KEY UPDATE
    idbangxephang = VALUES(idbangxephang),
    idchitietbxh = VALUES(idchitietbxh),
    idcapgiaidau = VALUES(idcapgiaidau),
    idkhuvuc = VALUES(idkhuvuc),
    mua_giai = VALUES(mua_giai),
    hang_dat_duoc = VALUES(hang_dat_duoc),
    danhhieu = VALUES(danhhieu),
    ngay_cong_nhan = VALUES(ngay_cong_nhan),
    nguon_ghi_nhan = VALUES(nguon_ghi_nhan),
    ghi_chu = VALUES(ghi_chu),
    trangthai = VALUES(trangthai),
    ngaycapnhat = NOW();

-- =========================================================
-- 6. Cau hinh Giai TP.HCM: chi doi vo dich giai chinh thuc cap quan/huyen du tu cach
-- =========================================================
UPDATE giaidau
SET quymo = 4,
    tinhchat = 'CHINH_THUC',
    mota = 'Giải cấp tỉnh/thành giữa các quận/huyện; đội tham gia phải là đội vô địch giải chính thức cấp quận/huyện.',
    ngaycapnhat = NOW()
WHERE idgiaidau = 2;

UPDATE dieulegiaidau
SET noidung = 'Các quận/huyện tham gia thông qua đội vô địch giải chính thức cấp quận/huyện gần nhất.',
    so_doi_toi_thieu = 2,
    so_doi_toi_da = 8,
    cho_phep_dang_ky_tu_do = 0,
    yeu_cau_duyet_dang_ky = 1
WHERE idgiaidau = 2;

-- Cap nhat quy tac chon doi cua Giai TP.HCM: yeu cau VO_DICH cap QUAN_HUYEN.
UPDATE quytacchondoi
SET chedochondoi = 'KET_HOP',
    capdoituongthamgia = 'QUAN_HUYEN',
    soluongdoitoida = 8,
    yeu_cau_thanh_tich = 'VO_DICH',
    idcapgiaidau_thanh_tich_nguon = 3,
    hang_toi_thieu_duoc_phep = 1,
    so_mua_giai_gan_nhat_duoc_tinh = 1,
    cho_phep_btc_duyet_ngoai_le = 1,
    mota = 'Đội đại diện quận/huyện đủ điều kiện nếu vô địch giải chính thức cấp quận/huyện gần nhất; BTC có thể duyệt ngoại lệ có lý do.',
    trangthai = 'HOAT_DONG'
WHERE idgiaidau = 2;

INSERT INTO dieukienthamgiagiai(
    idgiaidau, idquytac, ten_dieukien, capdoituongthamgia,
    yeu_cau_thanh_tich, idcapgiaidau_thanh_tich_nguon,
    hang_toi_thieu_duoc_phep, so_mua_giai_gan_nhat_duoc_tinh,
    chi_tinh_giai_chinh_thuc, bat_buoc_cung_khuvuc,
    cho_phep_btc_duyet_ngoai_le, mota, trangthai
)
VALUES
(2,2,'Vô địch giải chính thức cấp quận/huyện gần nhất','QUAN_HUYEN','VO_DICH',3,1,1,1,1,1,
 'Điều kiện dùng để xét đội đại diện quận/huyện có quyền đăng ký Giải bóng chuyền TP.HCM 2026.', 'HOAT_DONG')
ON DUPLICATE KEY UPDATE
    idquytac = VALUES(idquytac),
    capdoituongthamgia = VALUES(capdoituongthamgia),
    yeu_cau_thanh_tich = VALUES(yeu_cau_thanh_tich),
    idcapgiaidau_thanh_tich_nguon = VALUES(idcapgiaidau_thanh_tich_nguon),
    hang_toi_thieu_duoc_phep = VALUES(hang_toi_thieu_duoc_phep),
    so_mua_giai_gan_nhat_duoc_tinh = VALUES(so_mua_giai_gan_nhat_duoc_tinh),
    chi_tinh_giai_chinh_thuc = VALUES(chi_tinh_giai_chinh_thuc),
    bat_buoc_cung_khuvuc = VALUES(bat_buoc_cung_khuvuc),
    cho_phep_btc_duyet_ngoai_le = VALUES(cho_phep_btc_duyet_ngoai_le),
    mota = VALUES(mota),
    trangthai = VALUES(trangthai),
    ngaycapnhat = NOW();

-- Tao suat tham du tu tung giai quan/huyen len Giai TP.HCM.
INSERT INTO suatthamdu(idsuat, idgiaidau_nguon, idgiaidau_dich, idcapgiaidau_nguon, idcapgiaidau_dich,
                       idkhuvucphamvi, loaisuat, soluongsuat, hang_toi_thieu, tieuchi_mota, trangthai)
VALUES
(101,101,2,3,2,10,'VO_DICH_CAP_DUOI',1,1,'Vô địch Gò Vấp được quyền tham gia Giải TP.HCM.', 'MO'),
(102,102,2,3,2,11,'VO_DICH_CAP_DUOI',1,1,'Vô địch Quận 1 được quyền tham gia Giải TP.HCM.', 'MO'),
(103,103,2,3,2,12,'VO_DICH_CAP_DUOI',1,1,'Vô địch Quận 12 được quyền tham gia Giải TP.HCM.', 'MO'),
(104,104,2,3,2,13,'VO_DICH_CAP_DUOI',1,1,'Vô địch Bình Thạnh được quyền tham gia Giải TP.HCM.', 'MO')
ON DUPLICATE KEY UPDATE
    idgiaidau_nguon = VALUES(idgiaidau_nguon),
    idgiaidau_dich = VALUES(idgiaidau_dich),
    idcapgiaidau_nguon = VALUES(idcapgiaidau_nguon),
    idcapgiaidau_dich = VALUES(idcapgiaidau_dich),
    idkhuvucphamvi = VALUES(idkhuvucphamvi),
    loaisuat = VALUES(loaisuat),
    soluongsuat = VALUES(soluongsuat),
    hang_toi_thieu = VALUES(hang_toi_thieu),
    tieuchi_mota = VALUES(tieuchi_mota),
    trangthai = VALUES(trangthai),
    ngaycapnhat = NOW();

-- =========================================================
-- 7. Sinh danh sach doi du dieu kien tham gia Giai TP.HCM tu thanh tich
-- =========================================================
CALL sp_tao_doi_du_dieu_kien_tu_thanhtich_v2(2);

-- Gan suat tham du tuong ung vao ban ghi du dieu kien.
UPDATE doidudieukienthamgia ddk
JOIN thanhtichdoibong tt ON tt.idthanhtich = ddk.idthanhtich
JOIN suatthamdu st ON st.idgiaidau_nguon = tt.idgiaidau AND st.idgiaidau_dich = ddk.idgiaidau
SET ddk.idsuat = st.idsuat,
    ddk.ghichu = CONCAT('Đủ điều kiện tham gia Giải TP.HCM nhờ thành tích ', tt.danhhieu, ' tại giải cấp quận/huyện.')
WHERE ddk.idgiaidau = 2
  AND ddk.nguon_dieukien = 'THANH_TICH';

-- Lien ket ho so dang ky cu va bo sung ho so moi cho cac doi du dieu kien.
UPDATE dangkygiaidau dkg
JOIN doidudieukienthamgia ddk ON ddk.idgiaidau = dkg.idgiaidau AND ddk.iddoibong = dkg.iddoibong
SET dkg.iddieukien = ddk.iddieukien,
    dkg.nguon_dang_ky = 'HE_THONG_DE_XUAT',
    dkg.lydo_xet_tu_cach = ddk.lydo_dieukien
WHERE dkg.idgiaidau = 2
  AND dkg.iddoibong IN (5,6);

INSERT INTO dangkygiaidau(idgiaidau, iddoibong, idhuanluyenvien, iddieukien, nguon_dang_ky,
                          lydo_xet_tu_cach, ngaydangky, trangthai)
SELECT
    2,
    ddk.iddoibong,
    db.idhuanluyenvien,
    ddk.iddieukien,
    'HE_THONG_DE_XUAT',
    ddk.lydo_dieukien,
    NOW(),
    'CHO_DUYET'
FROM doidudieukienthamgia ddk
JOIN doibong db ON db.iddoibong = ddk.iddoibong
WHERE ddk.idgiaidau = 2
  AND ddk.iddoibong IN (11,12)
ON DUPLICATE KEY UPDATE
    iddieukien = VALUES(iddieukien),
    nguon_dang_ky = VALUES(nguon_dang_ky),
    lydo_xet_tu_cach = VALUES(lydo_xet_tu_cach);

-- =========================================================
-- 8. Kiem tra nhanh du lieu sau khi seed
-- =========================================================
SELECT
    'ELIGIBLE_TEAMS_FOR_HCM_2026' AS check_name,
    gd.tengiaidau,
    db.tendoibong,
    kv.tenkhuvuc AS khu_vuc_dai_dien,
    tt.danhhieu,
    tt.hang_dat_duoc,
    gnguon.tengiaidau AS giai_nguon,
    ddk.nguon_dieukien,
    ddk.trangthai AS trangthai_tu_cach,
    dkg.trangthai AS trangthai_dang_ky
FROM doidudieukienthamgia ddk
JOIN giaidau gd ON gd.idgiaidau = ddk.idgiaidau
JOIN doibong db ON db.iddoibong = ddk.iddoibong
JOIN khuvuc kv ON kv.idkhuvuc = db.idkhuvucdaidien
LEFT JOIN thanhtichdoibong tt ON tt.idthanhtich = ddk.idthanhtich
LEFT JOIN giaidau gnguon ON gnguon.idgiaidau = tt.idgiaidau
LEFT JOIN dangkygiaidau dkg ON dkg.idgiaidau = ddk.idgiaidau AND dkg.iddoibong = ddk.iddoibong
WHERE ddk.idgiaidau = 2
ORDER BY kv.tenkhuvuc, db.tendoibong;

COMMIT;

