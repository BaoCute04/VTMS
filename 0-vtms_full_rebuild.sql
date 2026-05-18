
-- =========================================================
-- VTMS FULL REBUILD SCRIPT
-- Database: vtms
-- Target: MariaDB 10.4+ / MySQL 8+
-- Purpose: Rebuild schema from scratch for Volleyball Tournament Management System
-- Scope: National level and below only: QUOC_GIA, TINH_THANH, QUAN_HUYEN, DON_VI
-- =========================================================

DROP DATABASE IF EXISTS vtms;
CREATE DATABASE vtms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE vtms;

SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- =========================================================
-- 1. MASTER DATA: ROLE, REGION, COMPETITION LEVEL, ORGANIZER LEVEL
-- =========================================================

CREATE TABLE role (
    idrole INT PRIMARY KEY AUTO_INCREMENT,
    namerole VARCHAR(100) NOT NULL UNIQUE,
    mota VARCHAR(500) NULL,
    CONSTRAINT chk_role_namerole CHECK (namerole IN ('ADMIN','BAN_TO_CHUC','TRONG_TAI','HUAN_LUYEN_VIEN','VAN_DONG_VIEN','BIEN_TAP'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE khuvuc (
    idkhuvuc INT PRIMARY KEY AUTO_INCREMENT,
    makhuvuc VARCHAR(100) NOT NULL UNIQUE,
    tenkhuvuc VARCHAR(300) NOT NULL,
    capkhuvuc VARCHAR(50) NOT NULL,
    idkhuvuccha INT NULL,
    mota VARCHAR(1000) NULL,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'HOAT_DONG',
    ngaytao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngaycapnhat DATETIME NULL,
    CONSTRAINT fk_khuvuc_cha FOREIGN KEY (idkhuvuccha) REFERENCES khuvuc(idkhuvuc)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_khuvuc_cap CHECK (capkhuvuc IN ('QUOC_GIA','TINH_THANH','QUAN_HUYEN','XA_PHUONG','DON_VI')),
    CONSTRAINT chk_khuvuc_trangthai CHECK (trangthai IN ('HOAT_DONG','NGUNG_SU_DUNG'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE capgiaidau (
    idcapgiaidau INT PRIMARY KEY AUTO_INCREMENT,
    macapgiaidau VARCHAR(50) NOT NULL UNIQUE,
    tencapgiaidau VARCHAR(200) NOT NULL,
    capkhuvucphamvi VARCHAR(50) NOT NULL,
    capdoituongthamgia VARCHAR(50) NOT NULL,
    apdung_bangdau_macdinh TINYINT(1) NOT NULL DEFAULT 0,
    mota VARCHAR(1000) NULL,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'HOAT_DONG',
    CONSTRAINT chk_capgd_ma CHECK (macapgiaidau IN ('QUOC_GIA','TINH_THANH','QUAN_HUYEN','DON_VI')),
    CONSTRAINT chk_capgd_scope CHECK (capkhuvucphamvi IN ('QUOC_GIA','TINH_THANH','QUAN_HUYEN','DON_VI')),
    CONSTRAINT chk_capgd_participant CHECK (capdoituongthamgia IN ('TINH_THANH','QUAN_HUYEN','XA_PHUONG','DON_VI')),
    CONSTRAINT chk_capgd_trangthai CHECK (trangthai IN ('HOAT_DONG','NGUNG_SU_DUNG'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE capbantochuc (
    idcapbantochuc INT PRIMARY KEY AUTO_INCREMENT,
    macapbantochuc VARCHAR(50) NOT NULL UNIQUE,
    tencapbantochuc VARCHAR(200) NOT NULL,
    capkhuvucquanly VARCHAR(50) NOT NULL,
    thutu INT NOT NULL,
    mota VARCHAR(1000) NULL,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'HOAT_DONG',
    CONSTRAINT chk_capbtc_ma CHECK (macapbantochuc IN ('QUOC_GIA','TINH_THANH','QUAN_HUYEN','DON_VI')),
    CONSTRAINT chk_capbtc_kv CHECK (capkhuvucquanly IN ('QUOC_GIA','TINH_THANH','QUAN_HUYEN','DON_VI')),
    CONSTRAINT chk_capbtc_thutu CHECK (thutu > 0),
    CONSTRAINT chk_capbtc_trangthai CHECK (trangthai IN ('HOAT_DONG','NGUNG_SU_DUNG'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE quyencapbtc_capgiaidau (
    idquyen INT PRIMARY KEY AUTO_INCREMENT,
    idcapbantochuc INT NOT NULL,
    idcapgiaidau INT NOT NULL,
    duoc_tao_giai TINYINT(1) NOT NULL DEFAULT 1,
    duoc_quan_ly TINYINT(1) NOT NULL DEFAULT 1,
    ghichu VARCHAR(500) NULL,
    UNIQUE KEY uq_quyencapbtc_capgiaidau (idcapbantochuc, idcapgiaidau),
    CONSTRAINT fk_qcapbtc_capbtc FOREIGN KEY (idcapbantochuc) REFERENCES capbantochuc(idcapbantochuc)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_qcapbtc_capgd FOREIGN KEY (idcapgiaidau) REFERENCES capgiaidau(idcapgiaidau)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 2. ACCOUNTS AND USER PROFILES
-- =========================================================

CREATE TABLE taikhoan (
    idtaikhoan INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    sodienthoai VARCHAR(20) NULL UNIQUE,
    idrole INT NOT NULL,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'CHUA_KICH_HOAT',
    ngaytao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngaycapnhat DATETIME NULL,
    CONSTRAINT fk_taikhoan_role FOREIGN KEY (idrole) REFERENCES role(idrole)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_taikhoan_trangthai CHECK (trangthai IN ('HOAT_DONG','CHUA_KICH_HOAT','TAM_KHOA','DA_HUY','CHO_DUYET')),
    CONSTRAINT chk_taikhoan_email CHECK (email LIKE '%@%')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE nguoidung (
    idnguoidung INT PRIMARY KEY AUTO_INCREMENT,
    idtaikhoan INT NOT NULL UNIQUE,
    ten VARCHAR(100) NOT NULL,
    hodem VARCHAR(200) NOT NULL,
    gioitinh VARCHAR(20) NOT NULL,
    ngaysinh DATE NULL,
    quequan VARCHAR(500) NULL,
    diachi VARCHAR(500) NULL,
    avatar VARCHAR(500) NULL,
    cccd VARCHAR(20) NULL UNIQUE,
    ngaytao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngaycapnhat DATETIME NULL,
    CONSTRAINT fk_nguoidung_taikhoan FOREIGN KEY (idtaikhoan) REFERENCES taikhoan(idtaikhoan)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_nguoidung_gioitinh CHECK (gioitinh IN ('NAM','NU','KHAC'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE quantrivien (
    idquantrivien INT PRIMARY KEY AUTO_INCREMENT,
    idnguoidung INT NOT NULL UNIQUE,
    machucvu VARCHAR(100) NULL,
    ghichu VARCHAR(500) NULL,
    CONSTRAINT fk_qtv_nguoidung FOREIGN KEY (idnguoidung) REFERENCES nguoidung(idnguoidung)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE bantochuc (
    idbantochuc INT PRIMARY KEY AUTO_INCREMENT,
    idnguoidung INT NOT NULL UNIQUE,
    idcapbantochuc INT NOT NULL,
    idkhuvucquanly INT NOT NULL,
    idbantochuccha INT NULL,
    donvi VARCHAR(300) NOT NULL,
    chucvu VARCHAR(200) NULL,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'CHO_XAC_NHAN',
    CONSTRAINT fk_btc_nguoidung FOREIGN KEY (idnguoidung) REFERENCES nguoidung(idnguoidung)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_btc_capbtc FOREIGN KEY (idcapbantochuc) REFERENCES capbantochuc(idcapbantochuc)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_btc_khuvuc FOREIGN KEY (idkhuvucquanly) REFERENCES khuvuc(idkhuvuc)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_btc_cha FOREIGN KEY (idbantochuccha) REFERENCES bantochuc(idbantochuc)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_btc_trangthai CHECK (trangthai IN ('HOAT_DONG','CHO_XAC_NHAN','TAM_KHOA','NGUNG_HOAT_DONG'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE trongtai (
    idtrongtai INT PRIMARY KEY AUTO_INCREMENT,
    idnguoidung INT NOT NULL UNIQUE,
    capbac VARCHAR(100) NULL,
    kinhnghiem INT NOT NULL DEFAULT 0,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'CHO_DUYET',
    CONSTRAINT fk_trongtai_nguoidung FOREIGN KEY (idnguoidung) REFERENCES nguoidung(idnguoidung)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_trongtai_kinhnghiem CHECK (kinhnghiem >= 0),
    CONSTRAINT chk_trongtai_trangthai CHECK (trangthai IN ('HOAT_DONG','CHO_DUYET','DANG_NGHI','NGUNG_HOAT_DONG'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE huanluyenvien (
    idhuanluyenvien INT PRIMARY KEY AUTO_INCREMENT,
    idnguoidung INT NOT NULL UNIQUE,
    bangcap VARCHAR(300) NULL,
    kinhnghiem INT NOT NULL DEFAULT 0,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'CHO_DUYET',
    CONSTRAINT fk_hlv_nguoidung FOREIGN KEY (idnguoidung) REFERENCES nguoidung(idnguoidung)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_hlv_kinhnghiem CHECK (kinhnghiem >= 0),
    CONSTRAINT chk_hlv_trangthai CHECK (trangthai IN ('CHO_DUYET','DA_XAC_NHAN','BI_HUY_TU_CACH','NGUNG_HOAT_DONG'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE vandongvien (
    idvandongvien INT PRIMARY KEY AUTO_INCREMENT,
    idnguoidung INT NOT NULL UNIQUE,
    mavandongvien VARCHAR(100) NOT NULL UNIQUE,
    chieucao DECIMAL(5,2) NULL,
    cannang DECIMAL(5,2) NULL,
    vitri VARCHAR(100) NOT NULL,
    trangthaidaugiai VARCHAR(50) NOT NULL DEFAULT 'CHO_XAC_NHAN',
    CONSTRAINT fk_vdv_nguoidung FOREIGN KEY (idnguoidung) REFERENCES nguoidung(idnguoidung)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_vdv_chieucao CHECK (chieucao IS NULL OR chieucao > 0),
    CONSTRAINT chk_vdv_cannang CHECK (cannang IS NULL OR cannang > 0),
    CONSTRAINT chk_vdv_vitri CHECK (vitri IN ('CHU_CONG','PHU_CONG','CHUYEN_HAI','DOI_CHUYEN','LIBERO','DOI_TRU')),
    CONSTRAINT chk_vdv_trangthai CHECK (trangthaidaugiai IN ('DU_DIEU_KIEN','CHO_XAC_NHAN','BI_HUY_TU_CACH','DANG_NGHI_PHEP'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 3. VOLLEYBALL RULES, TOURNAMENT REGULATIONS, FORMAT CONFIGURATION
-- =========================================================

CREATE TABLE luatthidau (
    idluat INT PRIMARY KEY AUTO_INCREMENT,
    tenluat VARCHAR(300) NOT NULL,
    phienban VARCHAR(100) NULL,
    so_vdv_thi_dau INT NOT NULL DEFAULT 6,
    so_vdv_du_bi INT NOT NULL DEFAULT 6,
    tong_vdv_toi_da INT NOT NULL DEFAULT 12,
    kieu_tran VARCHAR(20) NOT NULL DEFAULT 'BO5',
    so_set_thang_tran INT NOT NULL DEFAULT 3,
    diem_set_thuong INT NOT NULL DEFAULT 25,
    diem_set_quyet_dinh INT NOT NULL DEFAULT 15,
    cach_biet_toi_thieu INT NOT NULL DEFAULT 2,
    noidung_mota VARCHAR(3000) NULL,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'HOAT_DONG',
    CONSTRAINT chk_luat_kieu CHECK (kieu_tran IN ('BO3','BO5')),
    CONSTRAINT chk_luat_soluong CHECK (so_vdv_thi_dau > 0 AND so_vdv_du_bi >= 0 AND tong_vdv_toi_da >= so_vdv_thi_dau),
    CONSTRAINT chk_luat_set CHECK (so_set_thang_tran IN (2,3) AND diem_set_thuong > 0 AND diem_set_quyet_dinh > 0 AND cach_biet_toi_thieu > 0),
    CONSTRAINT chk_luat_trangthai CHECK (trangthai IN ('HOAT_DONG','NGUNG_SU_DUNG'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE giaidau (
    idgiaidau INT PRIMARY KEY AUTO_INCREMENT,
    tengiaidau VARCHAR(300) NOT NULL,
    mota VARCHAR(1000) NULL,
    idcapgiaidau INT NOT NULL,
    idkhuvucphamvi INT NOT NULL,
    idbantochuc INT NOT NULL,
    idluat INT NOT NULL,
    thoigianbatdau DATE NOT NULL,
    thoigianketthuc DATE NOT NULL,
    quymo INT NOT NULL,
    hinhanh VARCHAR(500) NULL,
    tinhchat VARCHAR(100) NOT NULL DEFAULT 'CHINH_THUC',
    trangthai VARCHAR(50) NOT NULL DEFAULT 'NHAP',
    trangthaidangky VARCHAR(50) NOT NULL DEFAULT 'CHUA_MO',
    trangthaithietlap VARCHAR(50) NOT NULL DEFAULT 'DANG_THIET_LAP',
    ghichu_diadiem VARCHAR(500) NULL,
    ngaytao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngaycapnhat DATETIME NULL,
    UNIQUE KEY uq_giaidau_ten_ngay (tengiaidau, thoigianbatdau),
    KEY idx_giaidau_cap_khuvuc (idcapgiaidau, idkhuvucphamvi),
    CONSTRAINT fk_giaidau_cap FOREIGN KEY (idcapgiaidau) REFERENCES capgiaidau(idcapgiaidau)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_giaidau_khuvuc FOREIGN KEY (idkhuvucphamvi) REFERENCES khuvuc(idkhuvuc)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_giaidau_btc FOREIGN KEY (idbantochuc) REFERENCES bantochuc(idbantochuc)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_giaidau_luat FOREIGN KEY (idluat) REFERENCES luatthidau(idluat)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_giaidau_thoigian CHECK (thoigianketthuc >= thoigianbatdau),
    CONSTRAINT chk_giaidau_quymo CHECK (quymo > 0),
    CONSTRAINT chk_giaidau_tinhchat CHECK (tinhchat IN ('CHINH_THUC','GIAO_HUU','PHONG_TRAO','NOI_BO','MO_RONG')),
    CONSTRAINT chk_giaidau_trangthai CHECK (trangthai IN ('NHAP','CHUA_CONG_BO','DA_CONG_BO','DANG_DIEN_RA','DA_KET_THUC','DA_HUY')),
    CONSTRAINT chk_giaidau_dangky CHECK (trangthaidangky IN ('CHUA_MO','DANG_MO','DA_DONG')),
    CONSTRAINT chk_giaidau_thietlap CHECK (trangthaithietlap IN ('DANG_THIET_LAP','DA_KHOA_DOI','DA_TAO_CAU_TRUC','DA_TAO_TRAN','DA_CONG_BO_LICH'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE dieulegiaidau (
    iddieule INT PRIMARY KEY AUTO_INCREMENT,
    idgiaidau INT NOT NULL UNIQUE,
    tieude VARCHAR(300) NOT NULL,
    noidung VARCHAR(3000) NULL,
    filedinhkem VARCHAR(500) NULL,
    so_doi_toi_thieu INT NOT NULL DEFAULT 2,
    so_doi_toi_da INT NOT NULL,
    so_vdv_toi_thieu_moi_doi INT NOT NULL DEFAULT 6,
    so_vdv_toi_da_moi_doi INT NOT NULL DEFAULT 12,
    thoi_gian_mo_dang_ky DATETIME NULL,
    thoi_gian_dong_dang_ky DATETIME NULL,
    cho_phep_dang_ky_tu_do TINYINT(1) NOT NULL DEFAULT 1,
    yeu_cau_duyet_dang_ky TINYINT(1) NOT NULL DEFAULT 1,
    quy_dinh_bo_cuoc VARCHAR(1000) NULL,
    quy_dinh_khieu_nai VARCHAR(1000) NULL,
    ngaytao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_dieule_giaidau FOREIGN KEY (idgiaidau) REFERENCES giaidau(idgiaidau)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_dieule_doi CHECK (so_doi_toi_thieu >= 2 AND so_doi_toi_da >= so_doi_toi_thieu),
    CONSTRAINT chk_dieule_vdv CHECK (so_vdv_toi_thieu_moi_doi >= 1 AND so_vdv_toi_da_moi_doi >= so_vdv_toi_thieu_moi_doi),
    CONSTRAINT chk_dieule_time CHECK (thoi_gian_dong_dang_ky IS NULL OR thoi_gian_mo_dang_ky IS NULL OR thoi_gian_dong_dang_ky >= thoi_gian_mo_dang_ky)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE thethucgiaidau (
    idthethuc INT PRIMARY KEY AUTO_INCREMENT,
    idgiaidau INT NOT NULL UNIQUE,
    tenthethuc VARCHAR(300) NOT NULL,
    tong_so_vong INT NOT NULL DEFAULT 1,
    co_vong_diem TINYINT(1) NOT NULL DEFAULT 0,
    co_vong_loai TINYINT(1) NOT NULL DEFAULT 0,
    co_tranh_hang_ba TINYINT(1) NOT NULL DEFAULT 0,
    cach_xep_mac_dinh VARCHAR(50) NOT NULL DEFAULT 'HYBRID',
    seed_source_mac_dinh VARCHAR(100) NOT NULL DEFAULT 'BTC_NHAP_TAY',
    mota VARCHAR(2000) NULL,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'DANG_THIET_LAP',
    CONSTRAINT fk_thethuc_giaidau FOREIGN KEY (idgiaidau) REFERENCES giaidau(idgiaidau)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_thethuc_vong CHECK (tong_so_vong > 0),
    CONSTRAINT chk_thethuc_cachxep CHECK (cach_xep_mac_dinh IN ('RANDOM','SEEDED','POT_DRAW','MANUAL','HYBRID')),
    CONSTRAINT chk_thethuc_seed CHECK (seed_source_mac_dinh IN ('BANG_XEP_HANG_TRUOC','THU_HANG_VONG_TRUOC','DIEM_TICH_LUY','BTC_NHAP_TAY','KHONG_AP_DUNG')),
    CONSTRAINT chk_thethuc_trangthai CHECK (trangthai IN ('DANG_THIET_LAP','DA_XAC_NHAN','DA_HUY'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE quytacchondoi (
    idquytac INT PRIMARY KEY AUTO_INCREMENT,
    idgiaidau INT NOT NULL,
    chedochondoi VARCHAR(50) NOT NULL DEFAULT 'DANG_KY_THU_CONG',
    capdoituongthamgia VARCHAR(50) NOT NULL,
    soluongdoitoida INT NULL,
    mota VARCHAR(1000) NULL,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'HOAT_DONG',
    CONSTRAINT fk_qtcd_giaidau FOREIGN KEY (idgiaidau) REFERENCES giaidau(idgiaidau)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_qtcd_chedo CHECK (chedochondoi IN ('DANG_KY_THU_CONG','HE_THONG_GOI_Y','BTC_CHON_THU_CONG','KET_HOP')),
    CONSTRAINT chk_qtcd_cap CHECK (capdoituongthamgia IN ('TINH_THANH','QUAN_HUYEN','XA_PHUONG','DON_VI')),
    CONSTRAINT chk_qtcd_trangthai CHECK (trangthai IN ('HOAT_DONG','NGUNG_SU_DUNG'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 4. TEAMS AND MEMBERS
-- =========================================================

CREATE TABLE doibong (
    iddoibong INT PRIMARY KEY AUTO_INCREMENT,
    tendoibong VARCHAR(300) NOT NULL UNIQUE,
    logo VARCHAR(500) NULL,
    idkhuvucdaidien INT NOT NULL,
    diaphuong VARCHAR(300) NULL,
    mota VARCHAR(1000) NULL,
    idhuanluyenvien INT NOT NULL,
    diem_xep_hang DECIMAL(10,2) NOT NULL DEFAULT 0,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'CHO_DUYET',
    ngaytao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngaycapnhat DATETIME NULL,
    CONSTRAINT fk_doibong_khuvuc FOREIGN KEY (idkhuvucdaidien) REFERENCES khuvuc(idkhuvuc)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_doibong_hlv FOREIGN KEY (idhuanluyenvien) REFERENCES huanluyenvien(idhuanluyenvien)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_doibong_trangthai CHECK (trangthai IN ('HOAT_DONG','CHO_DUYET','TAM_KHOA','GIAI_THE'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE thanhviendoibong (
    idthanhvien INT PRIMARY KEY AUTO_INCREMENT,
    iddoibong INT NOT NULL,
    idvandongvien INT NOT NULL,
    vaitro VARCHAR(100) NOT NULL DEFAULT 'THANH_VIEN',
    trangthai VARCHAR(50) NOT NULL DEFAULT 'CHO_XAC_NHAN',
    ngaythamgia DATE NOT NULL,
    ngayroi DATE NULL,
    UNIQUE KEY uq_tvdb_doi_vdv (iddoibong, idvandongvien),
    CONSTRAINT fk_tvdb_doibong FOREIGN KEY (iddoibong) REFERENCES doibong(iddoibong)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_tvdb_vdv FOREIGN KEY (idvandongvien) REFERENCES vandongvien(idvandongvien)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_tvdb_vaitro CHECK (vaitro IN ('DOI_TRUONG','THANH_VIEN','DU_BI')),
    CONSTRAINT chk_tvdb_trangthai CHECK (trangthai IN ('CHO_XAC_NHAN','DANG_THAM_GIA','DA_ROI_DOI','BI_LOAI')),
    CONSTRAINT chk_tvdb_ngayroi CHECK (ngayroi IS NULL OR ngayroi >= ngaythamgia)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE loimoidoibong (
    idloimoi INT PRIMARY KEY AUTO_INCREMENT,
    iddoibong INT NOT NULL,
    idvandongvien INT NOT NULL,
    idhuanluyenvien INT NOT NULL,
    noidung VARCHAR(1000) NULL,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'CHO_PHAN_HOI',
    ngaygui DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngayphanhoi DATETIME NULL,
    ngayhethan DATETIME NOT NULL,
    CONSTRAINT fk_lmdb_doibong FOREIGN KEY (iddoibong) REFERENCES doibong(iddoibong)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_lmdb_vdv FOREIGN KEY (idvandongvien) REFERENCES vandongvien(idvandongvien)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_lmdb_hlv FOREIGN KEY (idhuanluyenvien) REFERENCES huanluyenvien(idhuanluyenvien)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_lmdb_trangthai CHECK (trangthai IN ('CHO_PHAN_HOI','DONG_Y','TU_CHOI','HET_HAN')),
    CONSTRAINT chk_lmdb_han CHECK (ngayhethan >= ngaygui),
    CONSTRAINT chk_lmdb_phanhoi CHECK (ngayphanhoi IS NULL OR ngayphanhoi >= ngaygui)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE lichsuthanhviendoibong (
    idlichsu INT PRIMARY KEY AUTO_INCREMENT,
    idthanhvien INT NOT NULL,
    hanhdong VARCHAR(100) NOT NULL,
    ghichu VARCHAR(1000) NULL,
    ngaythuchien DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    idnguoithuchien INT NULL,
    CONSTRAINT fk_lstvdb_thanhvien FOREIGN KEY (idthanhvien) REFERENCES thanhviendoibong(idthanhvien)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_lstvdb_taikhoan FOREIGN KEY (idnguoithuchien) REFERENCES taikhoan(idtaikhoan)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT chk_lstvdb_hanhdong CHECK (hanhdong IN ('THEM_THANH_VIEN','XOA_THANH_VIEN','CHUYEN_DOI_THANH_VIEN','CAP_NHAT_VAI_TRO'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE dangkygiaidau (
    iddangky INT PRIMARY KEY AUTO_INCREMENT,
    idgiaidau INT NOT NULL,
    iddoibong INT NOT NULL,
    idhuanluyenvien INT NOT NULL,
    ngaydangky DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'CHO_DUYET',
    lydotuchoi VARCHAR(1000) NULL,
    UNIQUE KEY uq_dkgd_doi (idgiaidau, iddoibong),
    CONSTRAINT fk_dkgd_giaidau FOREIGN KEY (idgiaidau) REFERENCES giaidau(idgiaidau)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_dkgd_doibong FOREIGN KEY (iddoibong) REFERENCES doibong(iddoibong)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_dkgd_hlv FOREIGN KEY (idhuanluyenvien) REFERENCES huanluyenvien(idhuanluyenvien)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_dkgd_trangthai CHECK (trangthai IN ('CHO_DUYET','DA_DUYET','TU_CHOI','DA_HUY')),
    CONSTRAINT chk_dkgd_lydo CHECK ((trangthai <> 'TU_CHOI') OR (lydotuchoi IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 5. VENUES, COURTS, ROUNDS, GROUPS, MATCHES, MATCH SLOTS
-- =========================================================

CREATE TABLE vitrithidau (
    idvitrithidau INT PRIMARY KEY AUTO_INCREMENT,
    tenvitrithidau VARCHAR(300) NOT NULL,
    idkhuvuc INT NOT NULL,
    diachi VARCHAR(500) NOT NULL,
    mota VARCHAR(1000) NULL,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'HOAT_DONG',
    UNIQUE KEY uq_vitri_ten_diachi (tenvitrithidau, diachi),
    CONSTRAINT fk_vitri_khuvuc FOREIGN KEY (idkhuvuc) REFERENCES khuvuc(idkhuvuc)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_vitri_trangthai CHECK (trangthai IN ('HOAT_DONG','DANG_BAO_TRI','NGUNG_SU_DUNG'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE sandau (
    idsandau INT PRIMARY KEY AUTO_INCREMENT,
    idvitrithidau INT NOT NULL,
    tensandau VARCHAR(300) NOT NULL,
    succhua INT NOT NULL DEFAULT 0,
    mota VARCHAR(1000) NULL,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'HOAT_DONG',
    ngaytao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngaycapnhat DATETIME NULL,
    UNIQUE KEY uq_sandau_vitri_ten (idvitrithidau, tensandau),
    CONSTRAINT fk_sandau_vitri FOREIGN KEY (idvitrithidau) REFERENCES vitrithidau(idvitrithidau)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_sandau_succhua CHECK (succhua >= 0),
    CONSTRAINT chk_sandau_trangthai CHECK (trangthai IN ('HOAT_DONG','DANG_BAO_TRI','NGUNG_SU_DUNG'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE vongdau (
    idvongdau INT PRIMARY KEY AUTO_INCREMENT,
    idgiaidau INT NOT NULL,
    tenvongdau VARCHAR(300) NOT NULL,
    loaivongdau VARCHAR(50) NOT NULL,
    thutu INT NOT NULL,
    so_doi_tham_gia INT NOT NULL,
    co_bangdau TINYINT(1) NOT NULL DEFAULT 0,
    so_bang_dau INT NULL,
    so_luot_dau INT NOT NULL DEFAULT 1,
    so_doi_vao_vong_sau INT NULL,
    so_doi_vao_moi_bang INT NULL,
    cach_chon_doi_di_tiep VARCHAR(100) NOT NULL DEFAULT 'KHONG_AP_DUNG',
    cach_xep_cap_dau VARCHAR(50) NOT NULL DEFAULT 'KHONG_AP_DUNG',
    seed_source VARCHAR(100) NOT NULL DEFAULT 'KHONG_AP_DUNG',
    co_tranh_hang_ba TINYINT(1) NOT NULL DEFAULT 0,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'NHAP',
    ngaytao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_vongdau_thutu (idgiaidau, thutu),
    CONSTRAINT fk_vongdau_giaidau FOREIGN KEY (idgiaidau) REFERENCES giaidau(idgiaidau)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_vongdau_loai CHECK (loaivongdau IN ('VONG_DIEM','VONG_LOAI','CHUNG_KET','TRANH_HANG_BA')),
    CONSTRAINT chk_vongdau_thutu CHECK (thutu > 0),
    CONSTRAINT chk_vongdau_sodoi CHECK (so_doi_tham_gia >= 2),
    CONSTRAINT chk_vongdau_bang CHECK ((co_bangdau = 0 AND (so_bang_dau IS NULL OR so_bang_dau = 0)) OR (co_bangdau = 1 AND so_bang_dau IS NOT NULL AND so_bang_dau > 0)),
    CONSTRAINT chk_vongdau_luot CHECK (so_luot_dau IN (1,2)),
    CONSTRAINT chk_vongdau_chondoi CHECK (cach_chon_doi_di_tiep IN ('TOP_N','TOP_N_MOI_BANG','THANG_DI_TIEP','BTC_CHON','KHONG_AP_DUNG')),
    CONSTRAINT chk_vongdau_cachxep CHECK (cach_xep_cap_dau IN ('RANDOM','SEEDED','POT_DRAW','MANUAL','HYBRID','KHONG_AP_DUNG')),
    CONSTRAINT chk_vongdau_seed CHECK (seed_source IN ('BANG_XEP_HANG_TRUOC','THU_HANG_VONG_TRUOC','DIEM_TICH_LUY','BTC_NHAP_TAY','KHONG_AP_DUNG')),
    CONSTRAINT chk_vongdau_trangthai CHECK (trangthai IN ('NHAP','DA_TAO_DOI','DA_TAO_TRAN','DA_CONG_BO_LICH','DANG_DIEN_RA','DA_KET_THUC','DA_HUY'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE doitrongvongdau (
    iddoitrongvong INT PRIMARY KEY AUTO_INCREMENT,
    idvongdau INT NOT NULL,
    iddoibong INT NOT NULL,
    seed_no INT NULL,
    thuhang_vongtruoc INT NULL,
    nguonvao VARCHAR(100) NOT NULL DEFAULT 'DANG_KY',
    trangthai VARCHAR(50) NOT NULL DEFAULT 'HOP_LE',
    ngaythem DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_dtvong (idvongdau, iddoibong),
    UNIQUE KEY uq_dtvong_seed (idvongdau, seed_no),
    CONSTRAINT fk_dtvong_vong FOREIGN KEY (idvongdau) REFERENCES vongdau(idvongdau)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_dtvong_doi FOREIGN KEY (iddoibong) REFERENCES doibong(iddoibong)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_dtvong_seed CHECK (seed_no IS NULL OR seed_no > 0),
    CONSTRAINT chk_dtvong_nguon CHECK (nguonvao IN ('DANG_KY','BXH_VONG_TRUOC','BTC_CHON','HE_THONG_CHON','DAC_CACH')),
    CONSTRAINT chk_dtvong_trangthai CHECK (trangthai IN ('HOP_LE','BI_LOAI','DI_TIEP','CHO_XAC_NHAN'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE bangdau (
    idbangdau INT PRIMARY KEY AUTO_INCREMENT,
    idgiaidau INT NOT NULL,
    idvongdau INT NOT NULL,
    tenbang VARCHAR(100) NOT NULL,
    mota VARCHAR(500) NULL,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'HOAT_DONG',
    ngaytao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_bangdau_ten (idvongdau, tenbang),
    CONSTRAINT fk_bangdau_giaidau FOREIGN KEY (idgiaidau) REFERENCES giaidau(idgiaidau)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_bangdau_vong FOREIGN KEY (idvongdau) REFERENCES vongdau(idvongdau)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_bangdau_trangthai CHECK (trangthai IN ('HOAT_DONG','DA_XOA','DA_KHOA'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE doitrongbang (
    iddoitrongbang INT PRIMARY KEY AUTO_INCREMENT,
    idbangdau INT NOT NULL,
    iddoibong INT NOT NULL,
    ngaythem DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_dtb (idbangdau, iddoibong),
    CONSTRAINT fk_dtb_bang FOREIGN KEY (idbangdau) REFERENCES bangdau(idbangdau)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_dtb_doi FOREIGN KEY (iddoibong) REFERENCES doibong(iddoibong)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE phiensinhtran (
    idphien INT PRIMARY KEY AUTO_INCREMENT,
    idgiaidau INT NOT NULL,
    idvongdau INT NOT NULL,
    kieu_sinh VARCHAR(50) NOT NULL,
    cach_xep_cap_dau VARCHAR(50) NOT NULL,
    ghichu VARCHAR(1000) NULL,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'BAN_NHAP',
    idnguoitao INT NULL,
    ngaytao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngayxacnhan DATETIME NULL,
    CONSTRAINT fk_pst_giaidau FOREIGN KEY (idgiaidau) REFERENCES giaidau(idgiaidau)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_pst_vong FOREIGN KEY (idvongdau) REFERENCES vongdau(idvongdau)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_pst_taikhoan FOREIGN KEY (idnguoitao) REFERENCES taikhoan(idtaikhoan)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT chk_pst_kieu CHECK (kieu_sinh IN ('VONG_DIEM','VONG_LOAI','CHUNG_KET','TRANH_HANG_BA')),
    CONSTRAINT chk_pst_cach CHECK (cach_xep_cap_dau IN ('RANDOM','SEEDED','POT_DRAW','MANUAL','HYBRID','KHONG_AP_DUNG')),
    CONSTRAINT chk_pst_trangthai CHECK (trangthai IN ('BAN_NHAP','CHO_XAC_NHAN','DA_XAC_NHAN','DA_HUY'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE trandau (
    idtrandau INT PRIMARY KEY AUTO_INCREMENT,
    idgiaidau INT NOT NULL,
    idvongdau INT NOT NULL,
    idbangdau INT NULL,
    ma_tran VARCHAR(100) NOT NULL,
    ten_tran VARCHAR(300) NULL,
    iddoibong1 INT NULL,
    iddoibong2 INT NULL,
    idsandau INT NULL,
    thoigianbatdau DATETIME NULL,
    thoigianketthuc DATETIME NULL,
    thutu_tran INT NOT NULL,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'CHO_DOI_DOI',
    ngaytao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngaycapnhat DATETIME NULL,
    UNIQUE KEY uq_trandau_ma (idgiaidau, ma_tran),
    KEY idx_trandau_vong (idvongdau),
    KEY idx_trandau_doi1 (iddoibong1),
    KEY idx_trandau_doi2 (iddoibong2),
    CONSTRAINT fk_trandau_giaidau FOREIGN KEY (idgiaidau) REFERENCES giaidau(idgiaidau)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_trandau_vong FOREIGN KEY (idvongdau) REFERENCES vongdau(idvongdau)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_trandau_bang FOREIGN KEY (idbangdau) REFERENCES bangdau(idbangdau)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_trandau_doi1 FOREIGN KEY (iddoibong1) REFERENCES doibong(iddoibong)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_trandau_doi2 FOREIGN KEY (iddoibong2) REFERENCES doibong(iddoibong)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_trandau_san FOREIGN KEY (idsandau) REFERENCES sandau(idsandau)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_trandau_2doi CHECK (iddoibong1 IS NULL OR iddoibong2 IS NULL OR iddoibong1 <> iddoibong2),
    CONSTRAINT chk_trandau_thoigian CHECK (thoigianketthuc IS NULL OR thoigianbatdau IS NULL OR thoigianketthuc > thoigianbatdau),
    CONSTRAINT chk_trandau_thutu CHECK (thutu_tran > 0),
    CONSTRAINT chk_trandau_trangthai CHECK (trangthai IN ('CHO_DOI_DOI','CHO_XEP_LICH','DA_XEP_LICH','SAP_DIEN_RA','DANG_DIEN_RA','TAM_DUNG','DA_KET_THUC','DA_HUY'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE trandauslot (
    idslot INT PRIMARY KEY AUTO_INCREMENT,
    idtrandau INT NOT NULL,
    slot_so INT NOT NULL,
    source_type VARCHAR(50) NOT NULL DEFAULT 'TEAM',
    iddoibong INT NULL,
    source_match_id INT NULL,
    source_result VARCHAR(20) NULL,
    source_seed_no INT NULL,
    ghichu VARCHAR(500) NULL,
    UNIQUE KEY uq_slot_tran (idtrandau, slot_so),
    CONSTRAINT fk_slot_tran FOREIGN KEY (idtrandau) REFERENCES trandau(idtrandau)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_slot_doi FOREIGN KEY (iddoibong) REFERENCES doibong(iddoibong)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_slot_source_match FOREIGN KEY (source_match_id) REFERENCES trandau(idtrandau)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_slot_so CHECK (slot_so IN (1,2)),
    CONSTRAINT chk_slot_source_type CHECK (source_type IN ('TEAM','WINNER','LOSER','SEED','BYE')),
    CONSTRAINT chk_slot_source_result CHECK (source_result IS NULL OR source_result IN ('WINNER','LOSER')),
    CONSTRAINT chk_slot_seed CHECK (source_seed_no IS NULL OR source_seed_no > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 6. REFEREE MANAGEMENT AND MATCH SUPERVISION
-- =========================================================

CREATE TABLE phancongtrongtai (
    idphancong INT PRIMARY KEY AUTO_INCREMENT,
    idtrandau INT NOT NULL,
    idtrongtai INT NOT NULL,
    vaitro VARCHAR(100) NOT NULL,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'CHO_XAC_NHAN',
    ngayphancong DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_pctt (idtrandau, idtrongtai),
    CONSTRAINT fk_pctt_tran FOREIGN KEY (idtrandau) REFERENCES trandau(idtrandau)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_pctt_trongtai FOREIGN KEY (idtrongtai) REFERENCES trongtai(idtrongtai)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_pctt_vaitro CHECK (vaitro IN ('TRONG_TAI_CHINH','TRONG_TAI_PHU','GIAM_SAT')),
    CONSTRAINT chk_pctt_trangthai CHECK (trangthai IN ('CHO_XAC_NHAN','DA_XAC_NHAN','TU_CHOI','DA_HUY'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE trongtaitrandau (
    idtrongtaitrandau INT PRIMARY KEY AUTO_INCREMENT,
    idtrandau INT NOT NULL,
    idtrongtai INT NOT NULL,
    vaitro VARCHAR(100) NOT NULL,
    xacnhanthamgia TINYINT(1) NOT NULL DEFAULT 0,
    thoigianxacnhan DATETIME NULL,
    UNIQUE KEY uq_tttd (idtrandau, idtrongtai),
    CONSTRAINT fk_tttd_tran FOREIGN KEY (idtrandau) REFERENCES trandau(idtrandau)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_tttd_trongtai FOREIGN KEY (idtrongtai) REFERENCES trongtai(idtrongtai)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_tttd_vaitro CHECK (vaitro IN ('TRONG_TAI_CHINH','TRONG_TAI_PHU','GIAM_SAT')),
    CONSTRAINT chk_tttd_xacnhan CHECK ((xacnhanthamgia = 0 AND thoigianxacnhan IS NULL) OR (xacnhanthamgia = 1 AND thoigianxacnhan IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE sukientrandau (
    idsukien INT PRIMARY KEY AUTO_INCREMENT,
    idtrandau INT NOT NULL,
    loaisukien VARCHAR(100) NOT NULL,
    thoigian DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    noidung VARCHAR(1000) NOT NULL,
    idnguoitao INT NULL,
    CONSTRAINT fk_sktd_tran FOREIGN KEY (idtrandau) REFERENCES trandau(idtrandau)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_sktd_taikhoan FOREIGN KEY (idnguoitao) REFERENCES taikhoan(idtaikhoan)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT chk_sktd_loai CHECK (loaisukien IN ('BAT_DAU','TAM_DUNG','TIEP_TUC','KET_THUC','SU_CO','GHI_NHAN_DIEM'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE baocaosuco (
    idbaocao INT PRIMARY KEY AUTO_INCREMENT,
    idtrandau INT NOT NULL,
    idtrongtai INT NOT NULL,
    tieude VARCHAR(300) NOT NULL,
    noidung VARCHAR(2000) NOT NULL,
    minhchung VARCHAR(500) NULL,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'DA_GUI',
    ngaybaocao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_bcsc_tran FOREIGN KEY (idtrandau) REFERENCES trandau(idtrandau)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_bcsc_trongtai FOREIGN KEY (idtrongtai) REFERENCES trongtai(idtrongtai)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_bcsc_trangthai CHECK (trangthai IN ('DA_GUI','DA_TIEP_NHAN','DA_XU_LY','TU_CHOI'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE donnghitrongtai (
    iddonnghi INT PRIMARY KEY AUTO_INCREMENT,
    idtrongtai INT NOT NULL,
    tungay DATE NOT NULL,
    denngay DATE NOT NULL,
    lydo VARCHAR(1000) NOT NULL,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'CHO_DUYET',
    ngaygui DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngayxuly DATETIME NULL,
    CONSTRAINT fk_dntt_trongtai FOREIGN KEY (idtrongtai) REFERENCES trongtai(idtrongtai)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_dntt_ngay CHECK (denngay >= tungay),
    CONSTRAINT chk_dntt_xuly CHECK (ngayxuly IS NULL OR ngayxuly >= ngaygui),
    CONSTRAINT chk_dntt_trangthai CHECK (trangthai IN ('CHO_DUYET','DA_DUYET','TU_CHOI','DA_HUY'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 7. RESULTS, SET SCORES, STATISTICS, RANKINGS
-- =========================================================

CREATE TABLE ketquatrandau (
    idketqua INT PRIMARY KEY AUTO_INCREMENT,
    idtrandau INT NOT NULL UNIQUE,
    iddoithang INT NULL,
    iddoithua INT NULL,
    diemdoi1 INT NOT NULL DEFAULT 0,
    diemdoi2 INT NOT NULL DEFAULT 0,
    sosetdoi1 INT NOT NULL DEFAULT 0,
    sosetdoi2 INT NOT NULL DEFAULT 0,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'CHO_CONG_BO',
    ngayghinhan DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngaycongbo DATETIME NULL,
    idnguoighinhan INT NULL,
    CONSTRAINT fk_kqtd_tran FOREIGN KEY (idtrandau) REFERENCES trandau(idtrandau)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_kqtd_doithang FOREIGN KEY (iddoithang) REFERENCES doibong(iddoibong)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_kqtd_doithua FOREIGN KEY (iddoithua) REFERENCES doibong(iddoibong)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_kqtd_nguoighinhan FOREIGN KEY (idnguoighinhan) REFERENCES taikhoan(idtaikhoan)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT chk_kqtd_diem CHECK (diemdoi1 >= 0 AND diemdoi2 >= 0 AND sosetdoi1 >= 0 AND sosetdoi2 >= 0),
    CONSTRAINT chk_kqtd_set CHECK (sosetdoi1 <= 5 AND sosetdoi2 <= 5),
    CONSTRAINT chk_kqtd_trangthai CHECK (trangthai IN ('CHO_CONG_BO','DA_CONG_BO','DA_DIEU_CHINH','BI_HUY')),
    CONSTRAINT chk_kqtd_congbo CHECK (ngaycongbo IS NULL OR ngaycongbo >= ngayghinhan)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE diemset (
    iddiemset INT PRIMARY KEY AUTO_INCREMENT,
    idketqua INT NOT NULL,
    setthu INT NOT NULL,
    diemdoi1 INT NOT NULL DEFAULT 0,
    diemdoi2 INT NOT NULL DEFAULT 0,
    doithangset INT NOT NULL,
    UNIQUE KEY uq_diemset (idketqua, setthu),
    CONSTRAINT fk_diemset_ketqua FOREIGN KEY (idketqua) REFERENCES ketquatrandau(idketqua)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_diemset_doithang FOREIGN KEY (doithangset) REFERENCES doibong(iddoibong)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_diemset_setthu CHECK (setthu BETWEEN 1 AND 5),
    CONSTRAINT chk_diemset_diem CHECK (diemdoi1 >= 0 AND diemdoi2 >= 0 AND diemdoi1 <> diemdoi2)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE dieuchinhketqua (
    iddieuchinh INT PRIMARY KEY AUTO_INCREMENT,
    idketqua INT NOT NULL,
    diemcu VARCHAR(500) NOT NULL,
    diemmoi VARCHAR(500) NOT NULL,
    lydo VARCHAR(1000) NOT NULL,
    minhchung VARCHAR(500) NULL,
    idnguoichinhsua INT NULL,
    ngaychinhsua DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_dckq_ketqua FOREIGN KEY (idketqua) REFERENCES ketquatrandau(idketqua)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_dckq_taikhoan FOREIGN KEY (idnguoichinhsua) REFERENCES taikhoan(idtaikhoan)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE thongkedoi (
    idthongkedoi INT PRIMARY KEY AUTO_INCREMENT,
    idgiaidau INT NOT NULL,
    idvongdau INT NULL,
    idbangdau INT NULL,
    iddoibong INT NOT NULL,
    sotran INT NOT NULL DEFAULT 0,
    sotranthang INT NOT NULL DEFAULT 0,
    sotranthua INT NOT NULL DEFAULT 0,
    sosetthang INT NOT NULL DEFAULT 0,
    sosetthua INT NOT NULL DEFAULT 0,
    diem INT NOT NULL DEFAULT 0,
    UNIQUE KEY uq_tkd_scope (idgiaidau, idvongdau, idbangdau, iddoibong),
    CONSTRAINT fk_tkd_giaidau FOREIGN KEY (idgiaidau) REFERENCES giaidau(idgiaidau)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_tkd_vong FOREIGN KEY (idvongdau) REFERENCES vongdau(idvongdau)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_tkd_bang FOREIGN KEY (idbangdau) REFERENCES bangdau(idbangdau)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_tkd_doi FOREIGN KEY (iddoibong) REFERENCES doibong(iddoibong)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_tkd_nonnegative CHECK (sotran >= 0 AND sotranthang >= 0 AND sotranthua >= 0 AND sosetthang >= 0 AND sosetthua >= 0 AND diem >= 0),
    CONSTRAINT chk_tkd_tongtran CHECK (sotran >= sotranthang + sotranthua)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE thongkecanhan (
    idthongkecanhan INT PRIMARY KEY AUTO_INCREMENT,
    idvandongvien INT NOT NULL,
    idgiaidau INT NOT NULL,
    idtrandau INT NOT NULL,
    sodiem INT NOT NULL DEFAULT 0,
    solanphatbong INT NOT NULL DEFAULT 0,
    solanchanbong INT NOT NULL DEFAULT 0,
    solanghidiem INT NOT NULL DEFAULT 0,
    ghichu VARCHAR(1000) NULL,
    UNIQUE KEY uq_tkcn (idvandongvien, idgiaidau, idtrandau),
    CONSTRAINT fk_tkcn_vdv FOREIGN KEY (idvandongvien) REFERENCES vandongvien(idvandongvien)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_tkcn_giaidau FOREIGN KEY (idgiaidau) REFERENCES giaidau(idgiaidau)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_tkcn_tran FOREIGN KEY (idtrandau) REFERENCES trandau(idtrandau)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_tkcn_nonnegative CHECK (sodiem >= 0 AND solanphatbong >= 0 AND solanchanbong >= 0 AND solanghidiem >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE bangxephang (
    idbangxephang INT PRIMARY KEY AUTO_INCREMENT,
    idgiaidau INT NOT NULL,
    idvongdau INT NULL,
    idbangdau INT NULL,
    tenbangxephang VARCHAR(300) NOT NULL,
    phamvi VARCHAR(50) NOT NULL DEFAULT 'TOAN_GIAI',
    trangthai VARCHAR(50) NOT NULL DEFAULT 'BAN_NHAP',
    ngaytao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngaycongbo DATETIME NULL,
    UNIQUE KEY uq_bxh_scope (idgiaidau, idvongdau, idbangdau, tenbangxephang),
    CONSTRAINT fk_bxh_giaidau FOREIGN KEY (idgiaidau) REFERENCES giaidau(idgiaidau)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_bxh_vong FOREIGN KEY (idvongdau) REFERENCES vongdau(idvongdau)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_bxh_bang FOREIGN KEY (idbangdau) REFERENCES bangdau(idbangdau)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_bxh_phamvi CHECK (phamvi IN ('TOAN_GIAI','THEO_VONG','THEO_BANG')),
    CONSTRAINT chk_bxh_trangthai CHECK (trangthai IN ('BAN_NHAP','DA_CONG_BO','DA_CAP_NHAT')),
    CONSTRAINT chk_bxh_ngaycongbo CHECK (ngaycongbo IS NULL OR ngaycongbo >= ngaytao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE chitietbangxephang (
    idchitietbxh INT PRIMARY KEY AUTO_INCREMENT,
    idbangxephang INT NOT NULL,
    iddoibong INT NOT NULL,
    hang INT NOT NULL,
    sotran INT NOT NULL DEFAULT 0,
    thang INT NOT NULL DEFAULT 0,
    thua INT NOT NULL DEFAULT 0,
    sosetthang INT NOT NULL DEFAULT 0,
    sosetthua INT NOT NULL DEFAULT 0,
    diem INT NOT NULL DEFAULT 0,
    UNIQUE KEY uq_ctbxh_doi (idbangxephang, iddoibong),
    UNIQUE KEY uq_ctbxh_hang (idbangxephang, hang),
    CONSTRAINT fk_ctbxh_bxh FOREIGN KEY (idbangxephang) REFERENCES bangxephang(idbangxephang)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_ctbxh_doi FOREIGN KEY (iddoibong) REFERENCES doibong(iddoibong)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_ctbxh_hang CHECK (hang > 0),
    CONSTRAINT chk_ctbxh_nonnegative CHECK (sotran >= 0 AND thang >= 0 AND thua >= 0 AND sosetthang >= 0 AND sosetthua >= 0 AND diem >= 0),
    CONSTRAINT chk_ctbxh_tongtran CHECK (sotran >= thang + thua)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 8. LINEUPS, COMPLAINTS, LEAVE REQUESTS, NOTIFICATIONS, AUDIT LOGS
-- =========================================================

CREATE TABLE doihinh (
    iddoihinh INT PRIMARY KEY AUTO_INCREMENT,
    iddoibong INT NOT NULL,
    idgiaidau INT NOT NULL,
    tendoihinh VARCHAR(300) NOT NULL,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'BAN_NHAP',
    ngaytao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngaycapnhat DATETIME NULL,
    UNIQUE KEY uq_doihinh (iddoibong, idgiaidau, tendoihinh),
    CONSTRAINT fk_doihinh_doi FOREIGN KEY (iddoibong) REFERENCES doibong(iddoibong)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_doihinh_giaidau FOREIGN KEY (idgiaidau) REFERENCES giaidau(idgiaidau)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_doihinh_trangthai CHECK (trangthai IN ('BAN_NHAP','DA_CHOT','DA_CAP_NHAT'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE chitietdoihinh (
    idchitietdoihinh INT PRIMARY KEY AUTO_INCREMENT,
    iddoihinh INT NOT NULL,
    idvandongvien INT NOT NULL,
    vitri VARCHAR(100) NOT NULL,
    sothutu INT NULL,
    ghichu VARCHAR(500) NULL,
    UNIQUE KEY uq_ctdh_vdv (iddoihinh, idvandongvien),
    UNIQUE KEY uq_ctdh_sothutu (iddoihinh, sothutu),
    CONSTRAINT fk_ctdh_doihinh FOREIGN KEY (iddoihinh) REFERENCES doihinh(iddoihinh)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_ctdh_vdv FOREIGN KEY (idvandongvien) REFERENCES vandongvien(idvandongvien)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_ctdh_vitri CHECK (vitri IN ('CHU_CONG','PHU_CONG','CHUYEN_HAI','DOI_CHUYEN','LIBERO','DOI_TRU')),
    CONSTRAINT chk_ctdh_sothutu CHECK (sothutu IS NULL OR sothutu > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE khieunai (
    idkhieunai INT PRIMARY KEY AUTO_INCREMENT,
    idnguoigui INT NOT NULL,
    idgiaidau INT NOT NULL,
    idtrandau INT NULL,
    tieude VARCHAR(300) NOT NULL,
    noidung VARCHAR(2000) NOT NULL,
    minhchung VARCHAR(500) NULL,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'CHO_TIEP_NHAN',
    ngaygui DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngayxuly DATETIME NULL,
    idnguoixuly INT NULL,
    CONSTRAINT fk_khieunai_nguoigui FOREIGN KEY (idnguoigui) REFERENCES taikhoan(idtaikhoan)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_khieunai_giaidau FOREIGN KEY (idgiaidau) REFERENCES giaidau(idgiaidau)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_khieunai_tran FOREIGN KEY (idtrandau) REFERENCES trandau(idtrandau)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_khieunai_nguoixuly FOREIGN KEY (idnguoixuly) REFERENCES taikhoan(idtaikhoan)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT chk_khieunai_trangthai CHECK (trangthai IN ('CHO_TIEP_NHAN','DANG_XU_LY','DA_XU_LY','TU_CHOI','KHONG_XU_LY')),
    CONSTRAINT chk_khieunai_ngayxuly CHECK (ngayxuly IS NULL OR ngayxuly >= ngaygui)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE donnghivandongvien (
    iddonnghi INT PRIMARY KEY AUTO_INCREMENT,
    idvandongvien INT NOT NULL,
    idtrandau INT NULL,
    tungay DATE NOT NULL,
    denngay DATE NOT NULL,
    lydo VARCHAR(1000) NOT NULL,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'CHO_DUYET',
    ngaygui DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngayxuly DATETIME NULL,
    idnguoixuly INT NULL,
    CONSTRAINT fk_dnvdv_vdv FOREIGN KEY (idvandongvien) REFERENCES vandongvien(idvandongvien)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_dnvdv_tran FOREIGN KEY (idtrandau) REFERENCES trandau(idtrandau)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_dnvdv_nguoixuly FOREIGN KEY (idnguoixuly) REFERENCES taikhoan(idtaikhoan)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT chk_dnvdv_ngay CHECK (denngay >= tungay),
    CONSTRAINT chk_dnvdv_xuly CHECK (ngayxuly IS NULL OR ngayxuly >= ngaygui),
    CONSTRAINT chk_dnvdv_trangthai CHECK (trangthai IN ('CHO_DUYET','DA_DUYET','TU_CHOI','DA_HUY'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE yeucauxacnhan (
    idyeucau INT PRIMARY KEY AUTO_INCREMENT,
    loainguoigui VARCHAR(100) NOT NULL,
    idnguoigui INT NOT NULL,
    loainguoinhan VARCHAR(100) NOT NULL,
    idnguoinhan INT NOT NULL,
    loaixacnhan VARCHAR(100) NOT NULL,
    noidung VARCHAR(1000) NOT NULL,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'CHO_DUYET',
    ngaygui DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngayxuly DATETIME NULL,
    ghichu VARCHAR(500) NULL,
    CONSTRAINT chk_ycxn_loaixacnhan CHECK (loaixacnhan IN ('XAC_NHAN_HLV','XAC_NHAN_VDV','XAC_NHAN_THAY_DOI_HO_SO','XAC_NHAN_NGHI_PHEP','XAC_NHAN_TAI_KHOAN_TRONG_TAI','XAC_NHAN_DANG_KY_GIAI')),
    CONSTRAINT chk_ycxn_trangthai CHECK (trangthai IN ('CHO_DUYET','DA_DUYET','TU_CHOI','DA_HUY')),
    CONSTRAINT chk_ycxn_ngayxuly CHECK (ngayxuly IS NULL OR ngayxuly >= ngaygui)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE yeucaucapnhathoso (
    idyeucaucapnhat INT PRIMARY KEY AUTO_INCREMENT,
    idnguoidung INT NOT NULL,
    banglienquan VARCHAR(100) NOT NULL,
    truongcapnhat VARCHAR(100) NOT NULL,
    giatricu VARCHAR(1000) NULL,
    giatrimoi VARCHAR(1000) NOT NULL,
    lydo VARCHAR(1000) NULL,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'CHO_DUYET',
    ngaygui DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngayxuly DATETIME NULL,
    CONSTRAINT fk_yccnhs_nguoidung FOREIGN KEY (idnguoidung) REFERENCES nguoidung(idnguoidung)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_yccnhs_trangthai CHECK (trangthai IN ('CHO_DUYET','DA_DUYET','TU_CHOI')),
    CONSTRAINT chk_yccnhs_ngayxuly CHECK (ngayxuly IS NULL OR ngayxuly >= ngaygui)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE thongbao (
    idthongbao INT PRIMARY KEY AUTO_INCREMENT,
    idnguoinhan INT NOT NULL,
    tieude VARCHAR(300) NOT NULL,
    noidung VARCHAR(1000) NOT NULL,
    loai VARCHAR(100) NOT NULL,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'CHUA_DOC',
    ngaytao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngaydoc DATETIME NULL,
    CONSTRAINT fk_thongbao_taikhoan FOREIGN KEY (idnguoinhan) REFERENCES taikhoan(idtaikhoan)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_thongbao_loai CHECK (loai IN ('HE_THONG','XAC_NHAN','LICH_THI_DAU','KET_QUA','LOI_MOI_DOI_BONG','KHIEU_NAI')),
    CONSTRAINT chk_thongbao_trangthai CHECK (trangthai IN ('CHUA_DOC','DA_DOC','DA_XOA')),
    CONSTRAINT chk_thongbao_ngaydoc CHECK (ngaydoc IS NULL OR ngaydoc >= ngaytao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE nhatkyhethong (
    idnhatky INT PRIMARY KEY AUTO_INCREMENT,
    idtaikhoan INT NULL,
    hanhdong VARCHAR(300) NOT NULL,
    bangtacdong VARCHAR(100) NOT NULL,
    iddoituong INT NULL,
    thoigian DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ipaddress VARCHAR(100) NULL,
    ghichu VARCHAR(1000) NULL,
    CONSTRAINT fk_nkht_taikhoan FOREIGN KEY (idtaikhoan) REFERENCES taikhoan(idtaikhoan)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE nhatkytrangthai (
    idnhatkytrangthai INT PRIMARY KEY AUTO_INCREMENT,
    loaidoituong VARCHAR(100) NOT NULL,
    iddoituong INT NOT NULL,
    trangthaicu VARCHAR(100) NULL,
    trangthaimoi VARCHAR(100) NOT NULL,
    lydo VARCHAR(1000) NULL,
    idnguoithuchien INT NULL,
    thoigian DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_nktt_taikhoan FOREIGN KEY (idnguoithuchien) REFERENCES taikhoan(idtaikhoan)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT chk_nktt_loaidoituong CHECK (loaidoituong IN ('TAI_KHOAN','GIAI_DAU','DOI_BONG','SAN_DAU','TRAN_DAU','DANG_KY_GIAI','KHIEU_NAI','YEU_CAU_XAC_NHAN','VONG_DAU'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE lichsumatkhau (
    idlichsumatkhau INT PRIMARY KEY AUTO_INCREMENT,
    idtaikhoan INT NOT NULL,
    passwordold VARCHAR(255) NOT NULL,
    ngaythaydoi DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_lsmk_taikhoan FOREIGN KEY (idtaikhoan) REFERENCES taikhoan(idtaikhoan)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE phiendangnhap (
    idphien INT PRIMARY KEY AUTO_INCREMENT,
    idtaikhoan INT NOT NULL,
    token VARCHAR(500) NOT NULL UNIQUE,
    thoigiandangnhap DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    thoigiandangxuat DATETIME NULL,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'DANG_HOAT_DONG',
    CONSTRAINT fk_phien_taikhoan FOREIGN KEY (idtaikhoan) REFERENCES taikhoan(idtaikhoan)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_phien_trangthai CHECK (trangthai IN ('DANG_HOAT_DONG','DA_DANG_XUAT','HET_HAN')),
    CONSTRAINT chk_phien_thoigian CHECK (thoigiandangxuat IS NULL OR thoigiandangxuat >= thoigiandangnhap)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE lichsudangnhap (
    idlichsu INT PRIMARY KEY AUTO_INCREMENT,
    idtaikhoan INT NOT NULL,
    thoigian DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ipaddress VARCHAR(100) NULL,
    thietbi VARCHAR(300) NULL,
    ketqua VARCHAR(50) NOT NULL,
    ghichu VARCHAR(500) NULL,
    CONSTRAINT fk_lsdn_taikhoan FOREIGN KEY (idtaikhoan) REFERENCES taikhoan(idtaikhoan)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_lsdn_ketqua CHECK (ketqua IN ('THANH_CONG','THAT_BAI'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

-- =========================================================
-- FUNCTIONS, PROCEDURES, TRIGGERS
-- =========================================================
DELIMITER $$

CREATE FUNCTION fn_khuvuc_la_con(p_child INT, p_parent INT)
RETURNS TINYINT
READS SQL DATA
BEGIN
    DECLARE v_current INT;
    DECLARE v_parent INT;
    DECLARE v_counter INT DEFAULT 0;
    DECLARE v_not_found TINYINT DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_not_found = 1;

    IF p_child IS NULL OR p_parent IS NULL THEN
        RETURN 0;
    END IF;
    IF p_child = p_parent THEN
        RETURN 1;
    END IF;

    SET v_current = p_child;
    WHILE v_current IS NOT NULL AND v_counter < 50 DO
        SET v_not_found = 0;
        SELECT idkhuvuccha INTO v_parent FROM khuvuc WHERE idkhuvuc = v_current;
        IF v_not_found = 1 THEN
            RETURN 0;
        END IF;
        IF v_parent = p_parent THEN
            RETURN 1;
        END IF;
        SET v_current = v_parent;
        SET v_counter = v_counter + 1;
    END WHILE;
    RETURN 0;
END$$

CREATE PROCEDURE sp_cap_nhat_slot_tu_ketqua(IN p_idtrandau INT)
BEGIN
    DECLARE v_win INT;
    DECLARE v_lose INT;

    SELECT iddoithang, iddoithua INTO v_win, v_lose
    FROM ketquatrandau
    WHERE idtrandau = p_idtrandau
    ORDER BY idketqua DESC
    LIMIT 1;

    UPDATE trandauslot
    SET iddoibong = CASE
        WHEN source_result = 'WINNER' THEN v_win
        WHEN source_result = 'LOSER' THEN v_lose
        ELSE iddoibong
    END
    WHERE source_match_id = p_idtrandau
      AND source_type IN ('WINNER','LOSER');

    UPDATE trandau t
    LEFT JOIN trandauslot s1 ON s1.idtrandau = t.idtrandau AND s1.slot_so = 1
    LEFT JOIN trandauslot s2 ON s2.idtrandau = t.idtrandau AND s2.slot_so = 2
    SET t.iddoibong1 = s1.iddoibong,
        t.iddoibong2 = s2.iddoibong,
        t.trangthai = CASE
            WHEN s1.iddoibong IS NOT NULL AND s2.iddoibong IS NOT NULL AND t.trangthai = 'CHO_DOI_DOI'
            THEN 'CHO_XEP_LICH'
            ELSE t.trangthai
        END,
        t.ngaycapnhat = CURRENT_TIMESTAMP
    WHERE t.idtrandau IN (
        SELECT DISTINCT idtrandau
        FROM trandauslot
        WHERE source_match_id = p_idtrandau
    );
END$$

CREATE TRIGGER trg_khuvuc_bi
BEFORE INSERT ON khuvuc
FOR EACH ROW
BEGIN
    DECLARE v_capcha VARCHAR(50);
    IF NEW.idkhuvuccha IS NULL AND NEW.capkhuvuc <> 'QUOC_GIA' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Khu vực ngoài QUOC_GIA phải có khu vực cha.';
    END IF;
    IF NEW.idkhuvuccha IS NOT NULL THEN
        SELECT capkhuvuc INTO v_capcha FROM khuvuc WHERE idkhuvuc = NEW.idkhuvuccha;
        IF NEW.capkhuvuc = 'QUOC_GIA' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Khu vực QUOC_GIA không được có cha.';
        END IF;
        IF NEW.capkhuvuc = 'TINH_THANH' AND v_capcha <> 'QUOC_GIA' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'TINH_THANH phải thuộc QUOC_GIA.';
        END IF;
        IF NEW.capkhuvuc = 'QUAN_HUYEN' AND v_capcha <> 'TINH_THANH' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'QUAN_HUYEN phải thuộc TINH_THANH.';
        END IF;
        IF NEW.capkhuvuc = 'XA_PHUONG' AND v_capcha <> 'QUAN_HUYEN' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'XA_PHUONG phải thuộc QUAN_HUYEN.';
        END IF;
        IF NEW.capkhuvuc = 'DON_VI' AND v_capcha NOT IN ('XA_PHUONG','DON_VI') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DON_VI nên thuộc XA_PHUONG hoặc DON_VI cha.';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_bantochuc_bi
BEFORE INSERT ON bantochuc
FOR EACH ROW
BEGIN
    DECLARE v_capbtc VARCHAR(50);
    DECLARE v_capkv VARCHAR(50);
    DECLARE v_capcha INT;
    SELECT capkhuvucquanly INTO v_capbtc FROM capbantochuc WHERE idcapbantochuc = NEW.idcapbantochuc;
    SELECT capkhuvuc INTO v_capkv FROM khuvuc WHERE idkhuvuc = NEW.idkhuvucquanly;
    IF v_capbtc <> v_capkv THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cấp ban tổ chức phải khớp cấp khu vực quản lý.';
    END IF;
    IF NEW.idbantochuccha IS NOT NULL THEN
        SELECT idcapbantochuc INTO v_capcha FROM bantochuc WHERE idbantochuc = NEW.idbantochuccha;
        IF v_capcha >= NEW.idcapbantochuc THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BTC cha phải có cấp cao hơn BTC con.';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_giaidau_bi
BEFORE INSERT ON giaidau
FOR EACH ROW
BEGIN
    DECLARE v_capphamvi VARCHAR(50);
    DECLARE v_capkv VARCHAR(50);
    DECLARE v_btc_cap INT;
    DECLARE v_btc_kv INT;
    DECLARE v_btc_status VARCHAR(50);
    DECLARE v_count INT;

    SELECT capkhuvucphamvi INTO v_capphamvi FROM capgiaidau WHERE idcapgiaidau = NEW.idcapgiaidau;
    SELECT capkhuvuc INTO v_capkv FROM khuvuc WHERE idkhuvuc = NEW.idkhuvucphamvi;
    IF v_capphamvi <> v_capkv THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Khu vực phạm vi không khớp cấp giải đấu.';
    END IF;

    SELECT idcapbantochuc, idkhuvucquanly, trangthai INTO v_btc_cap, v_btc_kv, v_btc_status
    FROM bantochuc WHERE idbantochuc = NEW.idbantochuc;
    IF v_btc_status <> 'HOAT_DONG' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BTC phải hoạt động mới được tạo giải.';
    END IF;
    IF v_btc_kv <> NEW.idkhuvucphamvi THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BTC chỉ được tạo giải trong khu vực mình quản lý.';
    END IF;
    SELECT COUNT(*) INTO v_count
    FROM quyencapbtc_capgiaidau
    WHERE idcapbantochuc = v_btc_cap AND idcapgiaidau = NEW.idcapgiaidau AND duoc_tao_giai = 1;
    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cấp BTC không có quyền tạo cấp giải đấu này.';
    END IF;
END$$

CREATE TRIGGER trg_dangkygiaidau_bi
BEFORE INSERT ON dangkygiaidau
FOR EACH ROW
BEGIN
    DECLARE v_scope INT;
    DECLARE v_capdoituong VARCHAR(50);
    DECLARE v_team_kv INT;
    DECLARE v_team_cap VARCHAR(50);
    DECLARE v_team_status VARCHAR(50);

    SELECT cg.capdoituongthamgia, gd.idkhuvucphamvi
    INTO v_capdoituong, v_scope
    FROM giaidau gd JOIN capgiaidau cg ON cg.idcapgiaidau = gd.idcapgiaidau
    WHERE gd.idgiaidau = NEW.idgiaidau;

    SELECT d.idkhuvucdaidien, k.capkhuvuc, d.trangthai
    INTO v_team_kv, v_team_cap, v_team_status
    FROM doibong d JOIN khuvuc k ON k.idkhuvuc = d.idkhuvucdaidien
    WHERE d.iddoibong = NEW.iddoibong;

    IF v_team_status <> 'HOAT_DONG' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Chỉ đội đang hoạt động mới được đăng ký giải.';
    END IF;
    IF v_team_cap <> v_capdoituong THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cấp đại diện của đội không phù hợp với cấp giải đấu.';
    END IF;
    IF fn_khuvuc_la_con(v_team_kv, v_scope) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đội đăng ký không thuộc phạm vi khu vực của giải.';
    END IF;
END$$

CREATE TRIGGER trg_vongdau_bi
BEFORE INSERT ON vongdau
FOR EACH ROW
BEGIN
    DECLARE v_cap VARCHAR(50);
    SELECT cg.macapgiaidau INTO v_cap
    FROM giaidau gd JOIN capgiaidau cg ON cg.idcapgiaidau = gd.idcapgiaidau
    WHERE gd.idgiaidau = NEW.idgiaidau;
    IF v_cap = 'QUOC_GIA' AND NEW.co_bangdau = 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Giải cấp quốc gia trong VTMS không áp dụng bảng đấu mặc định.';
    END IF;
    IF NEW.loaivongdau = 'VONG_DIEM' AND NEW.cach_chon_doi_di_tiep = 'THANG_DI_TIEP' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vòng điểm không dùng quy tắc thắng đi tiếp từng trận.';
    END IF;
END$$

CREATE TRIGGER trg_doitrongvong_bi
BEFORE INSERT ON doitrongvongdau
FOR EACH ROW
BEGIN
    DECLARE v_giaidau INT;
    DECLARE v_count INT;
    SELECT idgiaidau INTO v_giaidau FROM vongdau WHERE idvongdau = NEW.idvongdau;
    SELECT COUNT(*) INTO v_count FROM dangkygiaidau
    WHERE idgiaidau = v_giaidau AND iddoibong = NEW.iddoibong AND trangthai = 'DA_DUYET';
    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đội trong vòng đấu phải là đội đã được duyệt đăng ký giải.';
    END IF;
END$$

CREATE TRIGGER trg_bangdau_bi
BEFORE INSERT ON bangdau
FOR EACH ROW
BEGIN
    DECLARE v_giaidau INT;
    DECLARE v_cobang TINYINT;
    SELECT idgiaidau, co_bangdau INTO v_giaidau, v_cobang FROM vongdau WHERE idvongdau = NEW.idvongdau;
    IF v_giaidau <> NEW.idgiaidau THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bảng đấu phải thuộc đúng giải của vòng đấu.';
    END IF;
    IF v_cobang <> 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Chỉ tạo bảng đấu cho vòng đấu có co_bangdau = 1.';
    END IF;
END$$

CREATE TRIGGER trg_doitrongbang_bi
BEFORE INSERT ON doitrongbang
FOR EACH ROW
BEGIN
    DECLARE v_vong INT;
    DECLARE v_count INT;
    SELECT idvongdau INTO v_vong FROM bangdau WHERE idbangdau = NEW.idbangdau;
    SELECT COUNT(*) INTO v_count FROM doitrongvongdau
    WHERE idvongdau = v_vong AND iddoibong = NEW.iddoibong;
    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đội trong bảng phải thuộc danh sách đội của vòng đấu.';
    END IF;
END$$

CREATE TRIGGER trg_trandau_bi
BEFORE INSERT ON trandau
FOR EACH ROW
BEGIN
    DECLARE v_giaidau INT;
    DECLARE v_cobang TINYINT;
    DECLARE v_bang_vong INT;
    DECLARE v_count INT;

    SELECT idgiaidau, co_bangdau INTO v_giaidau, v_cobang FROM vongdau WHERE idvongdau = NEW.idvongdau;
    IF v_giaidau <> NEW.idgiaidau THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Trận đấu phải thuộc đúng giải của vòng đấu.';
    END IF;
    IF v_cobang = 1 AND NEW.idbangdau IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vòng có bảng đấu thì trận đấu phải thuộc một bảng đấu.';
    END IF;
    IF v_cobang = 0 AND NEW.idbangdau IS NOT NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vòng không có bảng đấu thì trận đấu không được gắn bảng đấu.';
    END IF;
    IF NEW.idbangdau IS NOT NULL THEN
        SELECT idvongdau INTO v_bang_vong FROM bangdau WHERE idbangdau = NEW.idbangdau;
        IF v_bang_vong <> NEW.idvongdau THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bảng đấu của trận phải thuộc đúng vòng đấu.';
        END IF;
    END IF;
    IF NEW.iddoibong1 IS NOT NULL THEN
        SELECT COUNT(*) INTO v_count FROM doitrongvongdau WHERE idvongdau = NEW.idvongdau AND iddoibong = NEW.iddoibong1;
        IF v_count = 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đội 1 không thuộc vòng đấu.'; END IF;
    END IF;
    IF NEW.iddoibong2 IS NOT NULL THEN
        SELECT COUNT(*) INTO v_count FROM doitrongvongdau WHERE idvongdau = NEW.idvongdau AND iddoibong = NEW.iddoibong2;
        IF v_count = 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đội 2 không thuộc vòng đấu.'; END IF;
    END IF;
END$$

CREATE TRIGGER trg_trandauslot_bi
BEFORE INSERT ON trandauslot
FOR EACH ROW
BEGIN
    DECLARE v_giaidau INT;
    DECLARE v_source_giaidau INT;
    DECLARE v_count INT;
    IF NEW.source_type = 'TEAM' AND NEW.iddoibong IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Slot TEAM phải có đội cụ thể.';
    END IF;
    IF NEW.source_type IN ('WINNER','LOSER') THEN
        IF NEW.source_match_id IS NULL OR NEW.source_result IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Slot WINNER/LOSER phải có source_match_id và source_result.';
        END IF;
        SELECT idgiaidau INTO v_giaidau FROM trandau WHERE idtrandau = NEW.idtrandau;
        SELECT idgiaidau INTO v_source_giaidau FROM trandau WHERE idtrandau = NEW.source_match_id;
        IF v_giaidau <> v_source_giaidau THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Trận nguồn của slot phải cùng giải đấu.';
        END IF;
    END IF;
    IF NEW.source_type = 'SEED' AND NEW.source_seed_no IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Slot SEED phải có source_seed_no.';
    END IF;
    IF NEW.iddoibong IS NOT NULL THEN
        SELECT COUNT(*) INTO v_count
        FROM trandau t JOIN doitrongvongdau dv ON dv.idvongdau = t.idvongdau AND dv.iddoibong = NEW.iddoibong
        WHERE t.idtrandau = NEW.idtrandau;
        IF v_count = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đội trong slot phải thuộc vòng đấu của trận.';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_ketqua_bi
BEFORE INSERT ON ketquatrandau
FOR EACH ROW
BEGIN
    DECLARE v_doi1 INT;
    DECLARE v_doi2 INT;
    DECLARE v_status VARCHAR(50);
    SELECT COALESCE(t.iddoibong1, s1.iddoibong), COALESCE(t.iddoibong2, s2.iddoibong), t.trangthai
    INTO v_doi1, v_doi2, v_status
    FROM trandau t
    LEFT JOIN trandauslot s1 ON s1.idtrandau = t.idtrandau AND s1.slot_so = 1
    LEFT JOIN trandauslot s2 ON s2.idtrandau = t.idtrandau AND s2.slot_so = 2
    WHERE t.idtrandau = NEW.idtrandau;

    IF v_doi1 IS NULL OR v_doi2 IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không thể ghi kết quả khi trận chưa đủ 2 đội.';
    END IF;
    IF NEW.iddoithang IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Kết quả phải xác định đội thắng.';
    END IF;
    IF NEW.iddoithang NOT IN (v_doi1, v_doi2) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đội thắng phải là một trong hai đội của trận.';
    END IF;
    IF NEW.iddoithua IS NULL THEN
        IF NEW.iddoithang = v_doi1 THEN SET NEW.iddoithua = v_doi2; ELSE SET NEW.iddoithua = v_doi1; END IF;
    END IF;
    IF NEW.iddoithua NOT IN (v_doi1, v_doi2) OR NEW.iddoithua = NEW.iddoithang THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đội thua phải là đội còn lại của trận.';
    END IF;
END$$

CREATE TRIGGER trg_ketqua_ai
AFTER INSERT ON ketquatrandau
FOR EACH ROW
BEGIN
    UPDATE trandau
    SET trangthai = 'DA_KET_THUC', thoigianketthuc = COALESCE(thoigianketthuc, NEW.ngayghinhan), ngaycapnhat = CURRENT_TIMESTAMP
    WHERE idtrandau = NEW.idtrandau;
    CALL sp_cap_nhat_slot_tu_ketqua(NEW.idtrandau);
END$$

CREATE TRIGGER trg_phancong_bi
BEFORE INSERT ON phancongtrongtai
FOR EACH ROW
BEGIN
    DECLARE v_ngay DATE;
    DECLARE v_count INT;
    SELECT DATE(thoigianbatdau) INTO v_ngay FROM trandau WHERE idtrandau = NEW.idtrandau;
    IF v_ngay IS NOT NULL THEN
        SELECT COUNT(*) INTO v_count
        FROM donnghitrongtai
        WHERE idtrongtai = NEW.idtrongtai
          AND trangthai = 'DA_DUYET'
          AND v_ngay BETWEEN tungay AND denngay;
        IF v_count > 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Trọng tài đang nghỉ phép trong ngày thi đấu.';
        END IF;
    END IF;
END$$

DELIMITER ;

-- =========================================================
-- VIEWS
-- =========================================================

CREATE OR REPLACE VIEW vw_cautruc_giaidau AS
SELECT gd.idgiaidau, gd.tengiaidau, cg.macapgiaidau, kv.tenkhuvuc AS khuvucphamvi,
       vd.idvongdau, vd.tenvongdau, vd.loaivongdau, vd.thutu, vd.co_bangdau,
       vd.so_bang_dau, vd.so_doi_tham_gia, vd.so_doi_vao_vong_sau, vd.trangthai AS trangthai_vong
FROM giaidau gd
JOIN capgiaidau cg ON cg.idcapgiaidau = gd.idcapgiaidau
JOIN khuvuc kv ON kv.idkhuvuc = gd.idkhuvucphamvi
LEFT JOIN vongdau vd ON vd.idgiaidau = gd.idgiaidau;

CREATE OR REPLACE VIEW vw_public_lichthidau AS
SELECT t.idtrandau, gd.tengiaidau, vd.tenvongdau, bd.tenbang, t.ma_tran, t.ten_tran,
       d1.tendoibong AS doi1, d2.tendoibong AS doi2,
       vt.tenvitrithidau, sd.tensandau, t.thoigianbatdau, t.trangthai
FROM trandau t
JOIN giaidau gd ON gd.idgiaidau = t.idgiaidau
JOIN vongdau vd ON vd.idvongdau = t.idvongdau
LEFT JOIN bangdau bd ON bd.idbangdau = t.idbangdau
LEFT JOIN doibong d1 ON d1.iddoibong = t.iddoibong1
LEFT JOIN doibong d2 ON d2.iddoibong = t.iddoibong2
LEFT JOIN sandau sd ON sd.idsandau = t.idsandau
LEFT JOIN vitrithidau vt ON vt.idvitrithidau = sd.idvitrithidau
WHERE gd.trangthai IN ('DA_CONG_BO','DANG_DIEN_RA','DA_KET_THUC');

CREATE OR REPLACE VIEW vw_public_ketqua AS
SELECT kq.idketqua, gd.tengiaidau, t.ma_tran, t.ten_tran,
       d1.tendoibong AS doi1, d2.tendoibong AS doi2, dt.tendoibong AS doithang,
       kq.sosetdoi1, kq.sosetdoi2, kq.diemdoi1, kq.diemdoi2, kq.trangthai
FROM ketquatrandau kq
JOIN trandau t ON t.idtrandau = kq.idtrandau
JOIN giaidau gd ON gd.idgiaidau = t.idgiaidau
LEFT JOIN doibong d1 ON d1.iddoibong = t.iddoibong1
LEFT JOIN doibong d2 ON d2.iddoibong = t.iddoibong2
LEFT JOIN doibong dt ON dt.iddoibong = kq.iddoithang
WHERE kq.trangthai IN ('DA_CONG_BO','DA_DIEU_CHINH');

CREATE OR REPLACE VIEW vw_public_bangxephang AS
SELECT bxh.idbangxephang, gd.tengiaidau, bxh.tenbangxephang, bxh.phamvi,
       ct.hang, d.tendoibong, ct.sotran, ct.thang, ct.thua, ct.sosetthang, ct.sosetthua, ct.diem
FROM bangxephang bxh
JOIN giaidau gd ON gd.idgiaidau = bxh.idgiaidau
JOIN chitietbangxephang ct ON ct.idbangxephang = bxh.idbangxephang
JOIN doibong d ON d.iddoibong = ct.iddoibong
WHERE bxh.trangthai IN ('DA_CONG_BO','DA_CAP_NHAT');

-- =========================================================
-- SEED DATA
-- =========================================================

INSERT INTO role(idrole, namerole, mota) VALUES
(1,'ADMIN','Quản trị viên hệ thống'),
(2,'BAN_TO_CHUC','Ban tổ chức giải đấu'),
(3,'TRONG_TAI','Trọng tài'),
(4,'HUAN_LUYEN_VIEN','Huấn luyện viên'),
(5,'VAN_DONG_VIEN','Vận động viên'),
(6,'BIEN_TAP','Biên tập viên nội dung');

INSERT INTO khuvuc(idkhuvuc, makhuvuc, tenkhuvuc, capkhuvuc, idkhuvuccha, mota) VALUES
(1,'VN','Việt Nam','QUOC_GIA',NULL,'Phạm vi quốc gia'),
(2,'HCM','TP. Hồ Chí Minh','TINH_THANH',1,'Tỉnh/thành thuộc Việt Nam'),
(3,'HN','Hà Nội','TINH_THANH',1,'Tỉnh/thành thuộc Việt Nam'),
(4,'DN','Đà Nẵng','TINH_THANH',1,'Tỉnh/thành thuộc Việt Nam'),
(5,'CT','Cần Thơ','TINH_THANH',1,'Tỉnh/thành thuộc Việt Nam'),
(10,'GV','Quận Gò Vấp','QUAN_HUYEN',2,'Quận/huyện thuộc TP.HCM'),
(11,'Q1','Quận 1','QUAN_HUYEN',2,'Quận/huyện thuộc TP.HCM'),
(12,'Q12','Quận 12','QUAN_HUYEN',2,'Quận/huyện thuộc TP.HCM'),
(13,'BT','Quận Bình Thạnh','QUAN_HUYEN',2,'Quận/huyện thuộc TP.HCM'),
(20,'P1_GV','Phường 1 - Gò Vấp','XA_PHUONG',10,'Xã/phường thuộc Gò Vấp'),
(21,'P3_GV','Phường 3 - Gò Vấp','XA_PHUONG',10,'Xã/phường thuộc Gò Vấp'),
(22,'P5_GV','Phường 5 - Gò Vấp','XA_PHUONG',10,'Xã/phường thuộc Gò Vấp'),
(23,'P25_BT','Phường 25 - Bình Thạnh','XA_PHUONG',13,'Xã/phường thuộc Bình Thạnh'),
(30,'IUH','Đại học Công nghiệp TP.HCM','DON_VI',20,'Đơn vị cơ sở'),
(31,'HUTECH','Đại học Công nghệ TP.HCM','DON_VI',23,'Đơn vị cơ sở'),
(40,'IUH_KCNTT','Khoa Công nghệ thông tin IUH','DON_VI',30,'Đơn vị trực thuộc IUH'),
(41,'IUH_KQTKD','Khoa Quản trị kinh doanh IUH','DON_VI',30,'Đơn vị trực thuộc IUH'),
(42,'IUH_KCK','Khoa Cơ khí IUH','DON_VI',30,'Đơn vị trực thuộc IUH');

INSERT INTO capgiaidau(idcapgiaidau, macapgiaidau, tencapgiaidau, capkhuvucphamvi, capdoituongthamgia, apdung_bangdau_macdinh, mota) VALUES
(1,'QUOC_GIA','Giải cấp quốc gia','QUOC_GIA','TINH_THANH',0,'Giải giữa các tỉnh/thành, không chia bảng mặc định'),
(2,'TINH_THANH','Giải cấp tỉnh/thành','TINH_THANH','QUAN_HUYEN',1,'Giải giữa các quận/huyện'),
(3,'QUAN_HUYEN','Giải cấp quận/huyện','QUAN_HUYEN','XA_PHUONG',1,'Giải giữa các xã/phường'),
(4,'DON_VI','Giải cấp đơn vị','DON_VI','DON_VI',1,'Giải giữa các đơn vị tự đăng ký');

INSERT INTO capbantochuc(idcapbantochuc, macapbantochuc, tencapbantochuc, capkhuvucquanly, thutu, mota) VALUES
(1,'QUOC_GIA','Ban tổ chức cấp quốc gia','QUOC_GIA',1,'Cấp cao nhất trong VTMS'),
(2,'TINH_THANH','Ban tổ chức cấp tỉnh/thành','TINH_THANH',2,'Quản lý tỉnh/thành'),
(3,'QUAN_HUYEN','Ban tổ chức cấp quận/huyện','QUAN_HUYEN',3,'Quản lý quận/huyện'),
(4,'DON_VI','Ban tổ chức cấp đơn vị','DON_VI',4,'Quản lý đơn vị/cơ sở');

INSERT INTO quyencapbtc_capgiaidau(idcapbantochuc, idcapgiaidau, duoc_tao_giai, duoc_quan_ly, ghichu) VALUES
(1,1,1,1,'BTC quốc gia tạo giải quốc gia'),
(2,2,1,1,'BTC tỉnh/thành tạo giải tỉnh/thành'),
(3,3,1,1,'BTC quận/huyện tạo giải quận/huyện'),
(4,4,1,1,'BTC đơn vị tạo giải đơn vị');

INSERT INTO taikhoan(idtaikhoan, username, password, email, sodienthoai, idrole, trangthai) VALUES
(1,'admin','hashed_admin','admin@vtms.vn','0900000001',1,'HOAT_DONG'),
(2,'btc_quocgia','hashed_btc','btc.quocgia@vtms.vn','0900000002',2,'HOAT_DONG'),
(3,'btc_hcm','hashed_btc','btc.hcm@vtms.vn','0900000003',2,'HOAT_DONG'),
(4,'btc_govap','hashed_btc','btc.govap@vtms.vn','0900000004',2,'HOAT_DONG'),
(5,'btc_iuh','hashed_btc','btc.iuh@vtms.vn','0900000005',2,'HOAT_DONG'),
(6,'ref_01','hashed_ref','ref01@vtms.vn','0900000006',3,'HOAT_DONG'),
(7,'ref_02','hashed_ref','ref02@vtms.vn','0900000007',3,'HOAT_DONG'),
(8,'hlv_hcm','hashed_hlv','hlv.hcm@vtms.vn','0900000008',4,'HOAT_DONG'),
(9,'hlv_hn','hashed_hlv','hlv.hn@vtms.vn','0900000009',4,'HOAT_DONG'),
(10,'hlv_dn','hashed_hlv','hlv.dn@vtms.vn','0900000010',4,'HOAT_DONG'),
(11,'hlv_ct','hashed_hlv','hlv.ct@vtms.vn','0900000011',4,'HOAT_DONG'),
(12,'vdv_01','hashed_vdv','vdv01@vtms.vn','0900000012',5,'HOAT_DONG'),
(13,'vdv_02','hashed_vdv','vdv02@vtms.vn','0900000013',5,'HOAT_DONG'),
(14,'vdv_03','hashed_vdv','vdv03@vtms.vn','0900000014',5,'HOAT_DONG'),
(15,'vdv_04','hashed_vdv','vdv04@vtms.vn','0900000015',5,'HOAT_DONG'),
(16,'vdv_05','hashed_vdv','vdv05@vtms.vn','0900000016',5,'HOAT_DONG'),
(17,'vdv_06','hashed_vdv','vdv06@vtms.vn','0900000017',5,'HOAT_DONG'),
(18,'vdv_07','hashed_vdv','vdv07@vtms.vn','0900000018',5,'HOAT_DONG'),
(19,'vdv_08','hashed_vdv','vdv08@vtms.vn','0900000019',5,'HOAT_DONG');

INSERT INTO nguoidung(idnguoidung, idtaikhoan, hodem, ten, gioitinh, ngaysinh, quequan, diachi, cccd) VALUES
(1,1,'Nguyễn','Admin','NAM','1990-01-01','Việt Nam','TP.HCM','001000000001'),
(2,2,'Trần','Quốc Gia','NAM','1985-02-01','Việt Nam','Hà Nội','001000000002'),
(3,3,'Lê','Hồ Chí Minh','NU','1988-03-01','TP.HCM','TP.HCM','001000000003'),
(4,4,'Phạm','Gò Vấp','NAM','1987-04-01','TP.HCM','Gò Vấp','001000000004'),
(5,5,'Võ','IUH','NU','1989-05-01','TP.HCM','IUH','001000000005'),
(6,6,'Đỗ','Trọng Tài Một','NAM','1980-06-01','TP.HCM','TP.HCM','001000000006'),
(7,7,'Bùi','Trọng Tài Hai','NU','1982-07-01','TP.HCM','TP.HCM','001000000007'),
(8,8,'Ngô','HLV HCM','NAM','1981-08-01','TP.HCM','TP.HCM','001000000008'),
(9,9,'Đặng','HLV Hà Nội','NAM','1983-09-01','Hà Nội','Hà Nội','001000000009'),
(10,10,'Hoàng','HLV Đà Nẵng','NU','1984-10-01','Đà Nẵng','Đà Nẵng','001000000010'),
(11,11,'Phan','HLV Cần Thơ','NAM','1986-11-01','Cần Thơ','Cần Thơ','001000000011'),
(12,12,'Vũ','VĐV Một','NAM','2002-01-01','TP.HCM','TP.HCM','001000000012'),
(13,13,'Mai','VĐV Hai','NU','2002-02-01','TP.HCM','TP.HCM','001000000013'),
(14,14,'Dương','VĐV Ba','NAM','2001-03-01','Hà Nội','Hà Nội','001000000014'),
(15,15,'Tạ','VĐV Bốn','NAM','2001-04-01','Đà Nẵng','Đà Nẵng','001000000015'),
(16,16,'Lý','VĐV Năm','NU','2003-05-01','Cần Thơ','Cần Thơ','001000000016'),
(17,17,'Cao','VĐV Sáu','NAM','2000-06-01','TP.HCM','Gò Vấp','001000000017'),
(18,18,'Hồ','VĐV Bảy','NAM','2000-07-01','TP.HCM','IUH','001000000018'),
(19,19,'Tô','VĐV Tám','NU','2000-08-01','TP.HCM','IUH','001000000019');

INSERT INTO quantrivien(idquantrivien, idnguoidung, machucvu, ghichu) VALUES (1,1,'SYS_ADMIN','Quản trị hệ thống');
INSERT INTO bantochuc(idbantochuc, idnguoidung, idcapbantochuc, idkhuvucquanly, idbantochuccha, donvi, chucvu, trangthai) VALUES
(1,2,1,1,NULL,'Liên đoàn Bóng chuyền Việt Nam','BTC cấp quốc gia','HOAT_DONG'),
(2,3,2,2,1,'BTC Bóng chuyền TP.HCM','BTC cấp tỉnh/thành','HOAT_DONG'),
(3,4,3,10,2,'BTC Bóng chuyền Gò Vấp','BTC cấp quận/huyện','HOAT_DONG'),
(4,5,4,30,3,'BTC Bóng chuyền IUH','BTC cấp đơn vị','HOAT_DONG');
INSERT INTO trongtai(idtrongtai, idnguoidung, capbac, kinhnghiem, trangthai) VALUES
(1,6,'Cấp quốc gia',10,'HOAT_DONG'),(2,7,'Cấp thành phố',6,'HOAT_DONG');
INSERT INTO huanluyenvien(idhuanluyenvien, idnguoidung, bangcap, kinhnghiem, trangthai) VALUES
(1,8,'HLV A',8,'DA_XAC_NHAN'),(2,9,'HLV A',7,'DA_XAC_NHAN'),(3,10,'HLV B',5,'DA_XAC_NHAN'),(4,11,'HLV B',5,'DA_XAC_NHAN');
INSERT INTO vandongvien(idvandongvien, idnguoidung, mavandongvien, chieucao, cannang, vitri, trangthaidaugiai) VALUES
(1,12,'VDV001',180,72,'CHU_CONG','DU_DIEU_KIEN'),(2,13,'VDV002',170,60,'LIBERO','DU_DIEU_KIEN'),
(3,14,'VDV003',182,74,'PHU_CONG','DU_DIEU_KIEN'),(4,15,'VDV004',185,78,'CHUYEN_HAI','DU_DIEU_KIEN'),
(5,16,'VDV005',176,65,'DOI_CHUYEN','DU_DIEU_KIEN'),(6,17,'VDV006',181,70,'CHU_CONG','DU_DIEU_KIEN'),
(7,18,'VDV007',179,68,'PHU_CONG','DU_DIEU_KIEN'),(8,19,'VDV008',168,58,'LIBERO','DU_DIEU_KIEN');

INSERT INTO luatthidau(idluat, tenluat, phienban, so_vdv_thi_dau, so_vdv_du_bi, tong_vdv_toi_da, kieu_tran, so_set_thang_tran, diem_set_thuong, diem_set_quyet_dinh, cach_biet_toi_thieu, noidung_mota) VALUES
(1,'Luật bóng chuyền trong nhà 6 người - BO5','VTMS-2026',6,6,12,'BO5',3,25,15,2,'Mẫu luật mặc định cho giải chính thức'),
(2,'Luật bóng chuyền trong nhà 6 người - BO3','VTMS-2026',6,6,12,'BO3',2,25,15,2,'Mẫu luật rút gọn cho giải phong trào');

INSERT INTO doibong(iddoibong, tendoibong, idkhuvucdaidien, diaphuong, idhuanluyenvien, diem_xep_hang, trangthai) VALUES
(1,'TP.HCM Eagles',2,'TP.HCM',1,92,'HOAT_DONG'),
(2,'Hà Nội Titans',3,'Hà Nội',2,90,'HOAT_DONG'),
(3,'Đà Nẵng Waves',4,'Đà Nẵng',3,84,'HOAT_DONG'),
(4,'Cần Thơ Lions',5,'Cần Thơ',4,78,'HOAT_DONG'),
(5,'Gò Vấp Spikers',10,'Gò Vấp',1,70,'HOAT_DONG'),
(6,'Quận 1 Servers',11,'Quận 1',2,68,'HOAT_DONG'),
(7,'Phường 1 Smashers',20,'Phường 1 Gò Vấp',1,60,'HOAT_DONG'),
(8,'Phường 3 Blockers',21,'Phường 3 Gò Vấp',2,58,'HOAT_DONG'),
(9,'Khoa CNTT IUH Falcons',40,'IUH',1,55,'HOAT_DONG'),
(10,'Khoa QTKD IUH Tigers',41,'IUH',2,50,'HOAT_DONG');

INSERT INTO thanhviendoibong(idthanhvien, iddoibong, idvandongvien, vaitro, trangthai, ngaythamgia) VALUES
(1,1,1,'DOI_TRUONG','DANG_THAM_GIA','2026-01-01'),(2,1,2,'THANH_VIEN','DANG_THAM_GIA','2026-01-01'),
(3,2,3,'DOI_TRUONG','DANG_THAM_GIA','2026-01-01'),(4,3,4,'DOI_TRUONG','DANG_THAM_GIA','2026-01-01'),
(5,4,5,'DOI_TRUONG','DANG_THAM_GIA','2026-01-01'),(6,5,6,'DOI_TRUONG','DANG_THAM_GIA','2026-01-01'),
(7,9,7,'DOI_TRUONG','DANG_THAM_GIA','2026-01-01'),(8,10,8,'DOI_TRUONG','DANG_THAM_GIA','2026-01-01');

INSERT INTO giaidau(idgiaidau, tengiaidau, mota, idcapgiaidau, idkhuvucphamvi, idbantochuc, idluat, thoigianbatdau, thoigianketthuc, quymo, tinhchat, trangthai, trangthaidangky, trangthaithietlap, ghichu_diadiem) VALUES
(1,'Giải bóng chuyền quốc gia VTMS 2026','Giải cấp quốc gia giữa các tỉnh/thành, không chia bảng',1,1,1,1,'2026-06-01','2026-06-20',4,'CHINH_THUC','DA_CONG_BO','DA_DONG','DA_TAO_TRAN','Địa điểm từng trận được chọn khi lập lịch'),
(2,'Giải bóng chuyền TP.HCM 2026','Giải cấp tỉnh/thành giữa các quận/huyện',2,2,2,2,'2026-07-01','2026-07-10',2,'PHONG_TRAO','DA_CONG_BO','DA_DONG','DA_KHOA_DOI','Địa điểm từng trận được chọn khi lập lịch'),
(3,'Giải bóng chuyền IUH 2026','Giải cấp đơn vị giữa các khoa/đơn vị trong IUH',4,30,4,2,'2026-08-01','2026-08-07',2,'NOI_BO','DA_CONG_BO','DA_DONG','DA_KHOA_DOI','Thi đấu tại IUH');

INSERT INTO dieulegiaidau(iddieule, idgiaidau, tieude, noidung, so_doi_toi_thieu, so_doi_toi_da, so_vdv_toi_thieu_moi_doi, so_vdv_toi_da_moi_doi, thoi_gian_mo_dang_ky, thoi_gian_dong_dang_ky, cho_phep_dang_ky_tu_do, yeu_cau_duyet_dang_ky, quy_dinh_bo_cuoc, quy_dinh_khieu_nai) VALUES
(1,1,'Điều lệ giải quốc gia 2026','Mỗi tỉnh/thành cử một đội đại diện. Cấp quốc gia không chia bảng mặc định.',2,16,6,12,'2026-05-01 08:00:00','2026-05-20 17:00:00',0,1,'Đội bỏ cuộc xử thua 0-3','Khiếu nại trong vòng 24 giờ'),
(2,2,'Điều lệ giải TP.HCM 2026','Các quận/huyện đăng ký đội đại diện.',2,8,6,12,'2026-06-01 08:00:00','2026-06-20 17:00:00',1,1,'Đội bỏ cuộc xử thua 0-2','Khiếu nại trong vòng 24 giờ'),
(3,3,'Điều lệ giải IUH 2026','Các đơn vị trong IUH tự đăng ký.',2,12,6,12,'2026-07-01 08:00:00','2026-07-20 17:00:00',1,1,'Đội bỏ cuộc xử thua 0-2','Khiếu nại trong vòng 24 giờ');

INSERT INTO thethucgiaidau(idthethuc, idgiaidau, tenthethuc, tong_so_vong, co_vong_diem, co_vong_loai, co_tranh_hang_ba, cach_xep_mac_dinh, seed_source_mac_dinh, mota, trangthai) VALUES
(1,1,'Vòng điểm kết hợp vòng loại trực tiếp',2,1,1,1,'HYBRID','THU_HANG_VONG_TRUOC','Quốc gia không chia bảng; vòng điểm chọn top 4 vào bán kết','DA_XAC_NHAN'),
(2,2,'Vòng điểm một lượt',1,1,0,0,'RANDOM','KHONG_AP_DUNG','Giải TP.HCM mẫu','DA_XAC_NHAN'),
(3,3,'Vòng điểm một lượt',1,1,0,0,'RANDOM','KHONG_AP_DUNG','Giải IUH mẫu','DA_XAC_NHAN');

INSERT INTO quytacchondoi(idquytac, idgiaidau, chedochondoi, capdoituongthamgia, soluongdoitoida, mota) VALUES
(1,1,'KET_HOP','TINH_THANH',16,'Hệ thống gợi ý theo đại diện tỉnh/thành, BTC duyệt danh sách'),
(2,2,'DANG_KY_THU_CONG','QUAN_HUYEN',8,'Quận/huyện đăng ký, BTC TP.HCM duyệt'),
(3,3,'DANG_KY_THU_CONG','DON_VI',12,'Đơn vị trong IUH đăng ký, BTC IUH duyệt');

INSERT INTO dangkygiaidau(iddangky, idgiaidau, iddoibong, idhuanluyenvien, ngaydangky, trangthai) VALUES
(1,1,1,1,'2026-05-05 09:00:00','DA_DUYET'),
(2,1,2,2,'2026-05-05 09:10:00','DA_DUYET'),
(3,1,3,3,'2026-05-05 09:20:00','DA_DUYET'),
(4,1,4,4,'2026-05-05 09:30:00','DA_DUYET'),
(5,2,5,1,'2026-06-05 09:00:00','DA_DUYET'),
(6,2,6,2,'2026-06-05 09:30:00','DA_DUYET'),
(7,3,9,1,'2026-07-05 09:00:00','DA_DUYET'),
(8,3,10,2,'2026-07-05 09:30:00','DA_DUYET');

INSERT INTO vitrithidau(idvitrithidau, tenvitrithidau, idkhuvuc, diachi, mota) VALUES
(1,'Nhà thi đấu Phú Thọ',2,'TP.HCM','Địa điểm thi đấu lớn tại TP.HCM'),
(2,'Nhà thi đấu IUH',30,'12 Nguyễn Văn Bảo, Gò Vấp','Địa điểm thi đấu của IUH');
INSERT INTO sandau(idsandau, idvitrithidau, tensandau, succhua, mota) VALUES
(1,1,'Sân trung tâm',3000,'Sân chính'),
(2,1,'Sân phụ 1',1000,'Sân phụ'),
(3,2,'Sân IUH 1',500,'Sân trong trường');

INSERT INTO vongdau(idvongdau, idgiaidau, tenvongdau, loaivongdau, thutu, so_doi_tham_gia, co_bangdau, so_bang_dau, so_luot_dau, so_doi_vao_vong_sau, so_doi_vao_moi_bang, cach_chon_doi_di_tiep, cach_xep_cap_dau, seed_source, co_tranh_hang_ba, trangthai) VALUES
(1,1,'Vòng điểm quốc gia','VONG_DIEM',1,4,0,0,1,4,NULL,'TOP_N','KHONG_AP_DUNG','KHONG_AP_DUNG',0,'DA_TAO_TRAN'),
(2,1,'Vòng loại trực tiếp quốc gia','VONG_LOAI',2,4,0,0,1,NULL,NULL,'THANG_DI_TIEP','SEEDED','THU_HANG_VONG_TRUOC',1,'DA_TAO_TRAN'),
(3,2,'Vòng điểm TP.HCM','VONG_DIEM',1,2,0,0,1,NULL,NULL,'KHONG_AP_DUNG','KHONG_AP_DUNG','KHONG_AP_DUNG',0,'DA_TAO_DOI'),
(4,3,'Vòng điểm IUH','VONG_DIEM',1,2,0,0,1,NULL,NULL,'KHONG_AP_DUNG','KHONG_AP_DUNG','KHONG_AP_DUNG',0,'DA_TAO_DOI');

INSERT INTO doitrongvongdau(iddoitrongvong, idvongdau, iddoibong, seed_no, nguonvao, trangthai) VALUES
(1,1,1,1,'DANG_KY','HOP_LE'),(2,1,2,2,'DANG_KY','HOP_LE'),(3,1,3,3,'DANG_KY','HOP_LE'),(4,1,4,4,'DANG_KY','HOP_LE'),
(5,2,1,1,'BXH_VONG_TRUOC','HOP_LE'),(6,2,2,2,'BXH_VONG_TRUOC','HOP_LE'),(7,2,3,3,'BXH_VONG_TRUOC','HOP_LE'),(8,2,4,4,'BXH_VONG_TRUOC','HOP_LE'),
(9,3,5,1,'DANG_KY','HOP_LE'),(10,3,6,2,'DANG_KY','HOP_LE'),
(11,4,9,1,'DANG_KY','HOP_LE'),(12,4,10,2,'DANG_KY','HOP_LE');

INSERT INTO phiensinhtran(idphien, idgiaidau, idvongdau, kieu_sinh, cach_xep_cap_dau, ghichu, trangthai, idnguoitao, ngayxacnhan) VALUES
(1,1,1,'VONG_DIEM','KHONG_AP_DUNG','BTC xác nhận sinh trận vòng điểm từ 4 đội đã duyệt','DA_XAC_NHAN',2,'2026-05-21 08:00:00'),
(2,1,2,'VONG_LOAI','SEEDED','BTC xác nhận sinh bán kết, chung kết và tranh hạng 3','DA_XAC_NHAN',2,'2026-05-21 08:30:00');

-- Vòng điểm quốc gia: 4 đội, vòng tròn 1 lượt = 6 trận
INSERT INTO trandau(idtrandau, idgiaidau, idvongdau, idbangdau, ma_tran, ten_tran, iddoibong1, iddoibong2, idsandau, thoigianbatdau, thutu_tran, trangthai) VALUES
(1,1,1,NULL,'QG-RR-01','TP.HCM vs Hà Nội',1,2,1,'2026-06-01 08:00:00',1,'DA_XEP_LICH'),
(2,1,1,NULL,'QG-RR-02','Đà Nẵng vs Cần Thơ',3,4,2,'2026-06-01 10:00:00',2,'DA_XEP_LICH'),
(3,1,1,NULL,'QG-RR-03','TP.HCM vs Đà Nẵng',1,3,1,'2026-06-03 08:00:00',3,'DA_XEP_LICH'),
(4,1,1,NULL,'QG-RR-04','Hà Nội vs Cần Thơ',2,4,2,'2026-06-03 10:00:00',4,'DA_XEP_LICH'),
(5,1,1,NULL,'QG-RR-05','TP.HCM vs Cần Thơ',1,4,1,'2026-06-05 08:00:00',5,'DA_XEP_LICH'),
(6,1,1,NULL,'QG-RR-06','Hà Nội vs Đà Nẵng',2,3,2,'2026-06-05 10:00:00',6,'DA_XEP_LICH'),
-- Vòng loại: bán kết, chung kết, tranh hạng 3. Chung kết/tranh hạng 3 chờ WINNER/LOSER từ bán kết.
(7,1,2,NULL,'QG-SF-01','Bán kết 1',1,4,1,'2026-06-10 08:00:00',1,'DA_XEP_LICH'),
(8,1,2,NULL,'QG-SF-02','Bán kết 2',2,3,2,'2026-06-10 10:00:00',2,'DA_XEP_LICH'),
(9,1,2,NULL,'QG-FINAL','Chung kết',NULL,NULL,1,'2026-06-15 18:00:00',3,'CHO_DOI_DOI'),
(10,1,2,NULL,'QG-THIRD','Tranh hạng 3',NULL,NULL,2,'2026-06-15 15:00:00',4,'CHO_DOI_DOI'),
-- Giải cấp tỉnh/thành và đơn vị mẫu
(11,2,3,NULL,'HCM-RR-01','Gò Vấp vs Quận 1',5,6,1,'2026-07-01 08:00:00',1,'DA_XEP_LICH'),
(12,3,4,NULL,'IUH-RR-01','Khoa CNTT vs Khoa QTKD',9,10,3,'2026-08-01 08:00:00',1,'DA_XEP_LICH');

INSERT INTO trandauslot(idtrandau, slot_so, source_type, iddoibong, source_match_id, source_result, source_seed_no, ghichu) VALUES
(1,1,'TEAM',1,NULL,NULL,NULL,'Đội cụ thể'),(1,2,'TEAM',2,NULL,NULL,NULL,'Đội cụ thể'),
(2,1,'TEAM',3,NULL,NULL,NULL,'Đội cụ thể'),(2,2,'TEAM',4,NULL,NULL,NULL,'Đội cụ thể'),
(3,1,'TEAM',1,NULL,NULL,NULL,'Đội cụ thể'),(3,2,'TEAM',3,NULL,NULL,NULL,'Đội cụ thể'),
(4,1,'TEAM',2,NULL,NULL,NULL,'Đội cụ thể'),(4,2,'TEAM',4,NULL,NULL,NULL,'Đội cụ thể'),
(5,1,'TEAM',1,NULL,NULL,NULL,'Đội cụ thể'),(5,2,'TEAM',4,NULL,NULL,NULL,'Đội cụ thể'),
(6,1,'TEAM',2,NULL,NULL,NULL,'Đội cụ thể'),(6,2,'TEAM',3,NULL,NULL,NULL,'Đội cụ thể'),
(7,1,'TEAM',1,NULL,NULL,NULL,'Seed 1'),(7,2,'TEAM',4,NULL,NULL,NULL,'Seed 4'),
(8,1,'TEAM',2,NULL,NULL,NULL,'Seed 2'),(8,2,'TEAM',3,NULL,NULL,NULL,'Seed 3'),
(9,1,'WINNER',NULL,7,'WINNER',NULL,'Thắng bán kết 1 vào chung kết'),
(9,2,'WINNER',NULL,8,'WINNER',NULL,'Thắng bán kết 2 vào chung kết'),
(10,1,'LOSER',NULL,7,'LOSER',NULL,'Thua bán kết 1 tranh hạng 3'),
(10,2,'LOSER',NULL,8,'LOSER',NULL,'Thua bán kết 2 tranh hạng 3'),
(11,1,'TEAM',5,NULL,NULL,NULL,'Đội cụ thể'),(11,2,'TEAM',6,NULL,NULL,NULL,'Đội cụ thể'),
(12,1,'TEAM',9,NULL,NULL,NULL,'Đội cụ thể'),(12,2,'TEAM',10,NULL,NULL,NULL,'Đội cụ thể');

INSERT INTO phancongtrongtai(idphancong, idtrandau, idtrongtai, vaitro, trangthai) VALUES
(1,7,1,'TRONG_TAI_CHINH','DA_XAC_NHAN'),(2,7,2,'TRONG_TAI_PHU','DA_XAC_NHAN'),
(3,8,1,'TRONG_TAI_CHINH','DA_XAC_NHAN'),(4,8,2,'TRONG_TAI_PHU','DA_XAC_NHAN');
INSERT INTO trongtaitrandau(idtrongtaitrandau, idtrandau, idtrongtai, vaitro, xacnhanthamgia, thoigianxacnhan) VALUES
(1,7,1,'TRONG_TAI_CHINH',1,'2026-06-10 07:30:00'),(2,8,1,'TRONG_TAI_CHINH',1,'2026-06-10 09:30:00');

-- Kết quả bán kết: trigger sẽ tự đưa đội thắng vào chung kết, đội thua vào tranh hạng 3.
INSERT INTO ketquatrandau(idketqua, idtrandau, iddoithang, iddoithua, diemdoi1, diemdoi2, sosetdoi1, sosetdoi2, trangthai, ngayghinhan, ngaycongbo, idnguoighinhan) VALUES
(1,7,1,4,75,60,3,0,'DA_CONG_BO','2026-06-10 09:30:00','2026-06-10 10:00:00',6),
(2,8,2,3,80,72,3,1,'DA_CONG_BO','2026-06-10 11:45:00','2026-06-10 12:00:00',6);

INSERT INTO diemset(iddiemset, idketqua, setthu, diemdoi1, diemdoi2, doithangset) VALUES
(1,1,1,25,20,1),(2,1,2,25,22,1),(3,1,3,25,18,1),
(4,2,1,25,20,2),(5,2,2,23,25,3),(6,2,3,25,22,2),(7,2,4,25,22,2);

INSERT INTO thongkedoi(idthongkedoi, idgiaidau, idvongdau, idbangdau, iddoibong, sotran, sotranthang, sotranthua, sosetthang, sosetthua, diem) VALUES
(1,1,1,NULL,1,3,3,0,9,2,9),(2,1,1,NULL,2,3,2,1,7,4,6),(3,1,1,NULL,3,3,1,2,5,7,3),(4,1,1,NULL,4,3,0,3,1,9,0);

INSERT INTO bangxephang(idbangxephang, idgiaidau, idvongdau, idbangdau, tenbangxephang, phamvi, trangthai, ngaycongbo) VALUES
(1,1,1,NULL,'Bảng xếp hạng vòng điểm quốc gia','THEO_VONG','DA_CONG_BO','2026-06-06 18:00:00'),
(2,1,NULL,NULL,'Bảng xếp hạng chung cuộc dự kiến','TOAN_GIAI','BAN_NHAP',NULL);
INSERT INTO chitietbangxephang(idchitietbxh, idbangxephang, iddoibong, hang, sotran, thang, thua, sosetthang, sosetthua, diem) VALUES
(1,1,1,1,3,3,0,9,2,9),(2,1,2,2,3,2,1,7,4,6),(3,1,3,3,3,1,2,5,7,3),(4,1,4,4,3,0,3,1,9,0);

INSERT INTO doihinh(iddoihinh, iddoibong, idgiaidau, tendoihinh, trangthai) VALUES
(1,1,1,'Đội hình chính TP.HCM','DA_CHOT'),(2,2,1,'Đội hình chính Hà Nội','DA_CHOT');
INSERT INTO chitietdoihinh(idchitietdoihinh, iddoihinh, idvandongvien, vitri, sothutu) VALUES
(1,1,1,'CHU_CONG',1),(2,1,2,'LIBERO',2),(3,2,3,'PHU_CONG',1);

INSERT INTO thongkecanhan(idthongkecanhan, idvandongvien, idgiaidau, idtrandau, sodiem, solanphatbong, solanchanbong, solanghidiem) VALUES
(1,1,1,7,18,12,5,18),(2,3,1,8,20,10,6,20);

INSERT INTO thongbao(idthongbao, idnguoinhan, tieude, noidung, loai, trangthai) VALUES
(1,8,'Lịch thi đấu bán kết','Đội TP.HCM thi đấu bán kết 1','LICH_THI_DAU','CHUA_DOC'),
(2,9,'Lịch thi đấu bán kết','Đội Hà Nội thi đấu bán kết 2','LICH_THI_DAU','CHUA_DOC');
INSERT INTO khieunai(idkhieunai, idnguoigui, idgiaidau, idtrandau, tieude, noidung, trangthai) VALUES
(1,8,1,7,'Khiếu nại mẫu','Nội dung khiếu nại mẫu cho trận bán kết','CHO_TIEP_NHAN');
INSERT INTO yeucauxacnhan(idyeucau, loainguoigui, idnguoigui, loainguoinhan, idnguoinhan, loaixacnhan, noidung, trangthai) VALUES
(1,'HUAN_LUYEN_VIEN',1,'BAN_TO_CHUC',1,'XAC_NHAN_DANG_KY_GIAI','Yêu cầu xác nhận đăng ký giải','DA_DUYET');
INSERT INTO yeucaucapnhathoso(idyeucaucapnhat, idnguoidung, banglienquan, truongcapnhat, giatricu, giatrimoi, lydo, trangthai) VALUES
(1,12,'Vandongvien','vitri','CHU_CONG','PHU_CONG','Thay đổi vị trí thi đấu','CHO_DUYET');
INSERT INTO donnghitrongtai(iddonnghi, idtrongtai, tungay, denngay, lydo, trangthai) VALUES
(1,2,'2026-06-20','2026-06-22','Việc cá nhân','CHO_DUYET');
INSERT INTO donnghivandongvien(iddonnghi, idvandongvien, idtrandau, tungay, denngay, lydo, trangthai, idnguoixuly) VALUES
(1,1,9,'2026-06-15','2026-06-15','Xin nghỉ mẫu chờ duyệt','CHO_DUYET',2);
INSERT INTO nhatkyhethong(idtaikhoan, hanhdong, bangtacdong, iddoituong, ipaddress, ghichu) VALUES
(2,'TAO_GIAI_DAU','giaidau',1,'127.0.0.1','Seed dữ liệu mẫu'),
(2,'XAC_NHAN_SINH_TRAN','phiensinhtran',2,'127.0.0.1','Seed dữ liệu mẫu');
INSERT INTO lichsudangnhap(idtaikhoan, ipaddress, thietbi, ketqua, ghichu) VALUES
(1,'127.0.0.1','Chrome','THANH_CONG','Đăng nhập mẫu'),
(2,'127.0.0.1','Chrome','THANH_CONG','Đăng nhập mẫu');
INSERT INTO phiendangnhap(idtaikhoan, token, trangthai) VALUES
(1,'sample_admin_token','DANG_HOAT_DONG'),(2,'sample_btc_token','DANG_HOAT_DONG');

-- =========================================================
-- CHECK SAMPLE: final and third-place match slots should be resolved after semifinal results
-- =========================================================
SELECT 'VTMS schema rebuild completed' AS message;
SELECT COUNT(*) AS so_bang FROM information_schema.tables WHERE table_schema = 'vtms' AND table_type = 'BASE TABLE';
SELECT t.idtrandau, t.ma_tran, t.ten_tran, d1.tendoibong AS doi1, d2.tendoibong AS doi2, t.trangthai
FROM trandau t
LEFT JOIN doibong d1 ON d1.iddoibong = t.iddoibong1
LEFT JOIN doibong d2 ON d2.iddoibong = t.iddoibong2
WHERE t.idtrandau IN (9,10)
ORDER BY t.idtrandau;
