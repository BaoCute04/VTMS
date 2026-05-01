-- ============================================================
-- VTMS - Volleyball Tournament Management System
-- MySQL 8+ / MariaDB 10.2+ compatible script
-- Chuc nang:
--   1. Tao database VTMS
--   2. Tao bang va rang buoc PK, FK, UNIQUE, CHECK, DEFAULT
--   3. Them du lieu mau an khop voi rang buoc
-- Luu y: Script co DROP DATABASE de chay lai nhieu lan trong moi truong hoc tap/test.
-- ============================================================

SET NAMES utf8mb4;
SET SQL_MODE = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

DROP DATABASE IF EXISTS VTMS;
CREATE DATABASE VTMS
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE VTMS;

-- ============================================================
-- I. Nhom tai khoan, vai tro, nguoi dung
-- ============================================================

CREATE TABLE `Role` (
  idrole              INT PRIMARY KEY AUTO_INCREMENT,
  namerole            VARCHAR(200) NOT NULL UNIQUE,
  mota                VARCHAR(500) NULL,

  CONSTRAINT chk_role_namerole
    CHECK (namerole IN ('ADMIN','BAN_TO_CHUC','TRONG_TAI','HUAN_LUYEN_VIEN','VAN_DONG_VIEN','KHAN_GIA'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Taikhoan (
  idtaikhoan          INT PRIMARY KEY AUTO_INCREMENT,
  username            VARCHAR(100) NOT NULL UNIQUE,
  password            VARCHAR(200) NOT NULL,
  email               VARCHAR(150) NOT NULL UNIQUE,
  sodienthoai         VARCHAR(20) NULL UNIQUE,
  idrole              INT NOT NULL,
  trangthai           VARCHAR(50) NOT NULL DEFAULT 'CHUA_KICH_HOAT',
  ngaytao             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ngaycapnhat         DATETIME NULL,

  CONSTRAINT fk_taikhoan_role
    FOREIGN KEY (idrole) REFERENCES `Role`(idrole)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_taikhoan_trangthai
    CHECK (trangthai IN ('HOAT_DONG','CHUA_KICH_HOAT','TAM_KHOA','DA_HUY','CHO_DUYET')),
  CONSTRAINT chk_taikhoan_email
    CHECK (email LIKE '%@%')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Lichsumatkhau (
  idlichsumatkhau     INT PRIMARY KEY AUTO_INCREMENT,
  idtaikhoan          INT NOT NULL,
  passwordold         VARCHAR(200) NOT NULL,
  ngaythaydoi         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_lsmk_taikhoan
    FOREIGN KEY (idtaikhoan) REFERENCES Taikhoan(idtaikhoan)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Phiendangnhap (
  idphien             INT PRIMARY KEY AUTO_INCREMENT,
  idtaikhoan          INT NOT NULL,
  token               VARCHAR(500) NOT NULL UNIQUE,
  thoigiandangnhap    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  thoigiandangxuat    DATETIME NULL,
  trangthai           VARCHAR(50) NOT NULL DEFAULT 'DANG_HOAT_DONG',

  CONSTRAINT fk_phien_taikhoan
    FOREIGN KEY (idtaikhoan) REFERENCES Taikhoan(idtaikhoan)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT chk_phien_trangthai
    CHECK (trangthai IN ('DANG_HOAT_DONG','DA_DANG_XUAT','HET_HAN')),
  CONSTRAINT chk_phien_thoigian
    CHECK (thoigiandangxuat IS NULL OR thoigiandangxuat >= thoigiandangnhap)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Lichsudangnhap (
  idlichsu            INT PRIMARY KEY AUTO_INCREMENT,
  idtaikhoan          INT NOT NULL,
  thoigian            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ipaddress           VARCHAR(100) NULL,
  thietbi             VARCHAR(300) NULL,
  ketqua              VARCHAR(50) NOT NULL,
  ghichu              VARCHAR(500) NULL,

  CONSTRAINT fk_lsdn_taikhoan
    FOREIGN KEY (idtaikhoan) REFERENCES Taikhoan(idtaikhoan)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT chk_lsdn_ketqua
    CHECK (ketqua IN ('THANH_CONG','THAT_BAI'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Nguoidung (
  idnguoidung         INT PRIMARY KEY AUTO_INCREMENT,
  idtaikhoan          INT NOT NULL UNIQUE,
  ten                 VARCHAR(100) NOT NULL,
  hodem               VARCHAR(200) NOT NULL,
  gioitinh            VARCHAR(20) NOT NULL,
  ngaysinh            DATE NULL,
  quequan             VARCHAR(500) NULL,
  diachi              VARCHAR(500) NULL,
  avatar              VARCHAR(500) NULL,
  cccd                VARCHAR(20) NULL UNIQUE,
  ngaytao             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ngaycapnhat         DATETIME NULL,

  CONSTRAINT fk_nguoidung_taikhoan
    FOREIGN KEY (idtaikhoan) REFERENCES Taikhoan(idtaikhoan)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT chk_nguoidung_gioitinh
    CHECK (gioitinh IN ('NAM','NU','KHAC'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Quantrivien (
  idquantrivien       INT PRIMARY KEY AUTO_INCREMENT,
  idnguoidung         INT NOT NULL UNIQUE,
  machucvu            VARCHAR(100) NULL,
  ghichu              VARCHAR(500) NULL,

  CONSTRAINT fk_qtv_nguoidung
    FOREIGN KEY (idnguoidung) REFERENCES Nguoidung(idnguoidung)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Bantochuc (
  idbantochuc         INT PRIMARY KEY AUTO_INCREMENT,
  idnguoidung         INT NOT NULL UNIQUE,
  donvi               VARCHAR(300) NOT NULL,
  chucvu              VARCHAR(200) NULL,
  trangthai           VARCHAR(50) NOT NULL DEFAULT 'CHO_XAC_NHAN',

  CONSTRAINT fk_btc_nguoidung
    FOREIGN KEY (idnguoidung) REFERENCES Nguoidung(idnguoidung)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT chk_btc_trangthai
    CHECK (trangthai IN ('HOAT_DONG','CHO_XAC_NHAN','TAM_KHOA','NGUNG_HOAT_DONG'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Trongtai (
  idtrongtai          INT PRIMARY KEY AUTO_INCREMENT,
  idnguoidung         INT NOT NULL UNIQUE,
  capbac              VARCHAR(100) NULL,
  kinhnghiem          INT NOT NULL DEFAULT 0,
  trangthai           VARCHAR(50) NOT NULL DEFAULT 'CHO_DUYET',

  CONSTRAINT fk_trongtai_nguoidung
    FOREIGN KEY (idnguoidung) REFERENCES Nguoidung(idnguoidung)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT chk_trongtai_kinhnghiem
    CHECK (kinhnghiem >= 0),
  CONSTRAINT chk_trongtai_trangthai
    CHECK (trangthai IN ('HOAT_DONG','CHO_DUYET','DANG_NGHI','NGUNG_HOAT_DONG'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Huanluyenvien (
  idhuanluyenvien     INT PRIMARY KEY AUTO_INCREMENT,
  idnguoidung         INT NOT NULL UNIQUE,
  bangcap             VARCHAR(300) NULL,
  kinhnghiem          INT NOT NULL DEFAULT 0,
  trangthai           VARCHAR(50) NOT NULL DEFAULT 'CHO_DUYET',

  CONSTRAINT fk_hlv_nguoidung
    FOREIGN KEY (idnguoidung) REFERENCES Nguoidung(idnguoidung)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT chk_hlv_kinhnghiem
    CHECK (kinhnghiem >= 0),
  CONSTRAINT chk_hlv_trangthai
    CHECK (trangthai IN ('CHO_DUYET','DA_XAC_NHAN','BI_HUY_TU_CACH','NGUNG_HOAT_DONG'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Vandongvien (
  idvandongvien       INT PRIMARY KEY AUTO_INCREMENT,
  idnguoidung         INT NOT NULL UNIQUE,
  mavandongvien       VARCHAR(100) NOT NULL UNIQUE,
  chieucao            FLOAT NULL,
  cannang             FLOAT NULL,
  vitri               VARCHAR(100) NOT NULL,
  trangthaidaugiai    VARCHAR(50) NOT NULL DEFAULT 'CHO_XAC_NHAN',

  CONSTRAINT fk_vdv_nguoidung
    FOREIGN KEY (idnguoidung) REFERENCES Nguoidung(idnguoidung)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT chk_vdv_chieucao
    CHECK (chieucao IS NULL OR chieucao > 0),
  CONSTRAINT chk_vdv_cannang
    CHECK (cannang IS NULL OR cannang > 0),
  CONSTRAINT chk_vdv_vitri
    CHECK (vitri IN ('CHU_CONG','PHU_CONG','CHUYEN_HAI','DOI_CHUYEN','LIBERO','DOI_TRU')),
  CONSTRAINT chk_vdv_trangthaidaugiai
    CHECK (trangthaidaugiai IN ('DU_DIEU_KIEN','CHO_XAC_NHAN','BI_HUY_TU_CACH','DANG_NGHI_PHEP'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- III. Nhom xac nhan, cap nhat ho so, thong bao, nhat ky
-- ============================================================

CREATE TABLE Yeucauxacnhan (
  idyeucau            INT PRIMARY KEY AUTO_INCREMENT,
  loainguoigui        VARCHAR(100) NOT NULL,
  idnguoigui          INT NOT NULL,
  loainguoinhan       VARCHAR(100) NOT NULL,
  idnguoinhan         INT NOT NULL,
  loaixacnhan         VARCHAR(100) NOT NULL,
  noidung             VARCHAR(1000) NOT NULL,
  trangthai           VARCHAR(50) NOT NULL DEFAULT 'CHO_DUYET',
  ngaygui             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ngayxuly            DATETIME NULL,
  ghichu              VARCHAR(500) NULL,

  CONSTRAINT chk_ycxn_loaixacnhan
    CHECK (loaixacnhan IN ('XAC_NHAN_HLV','XAC_NHAN_VDV','XAC_NHAN_THAY_DOI_HO_SO','XAC_NHAN_NGHI_PHEP','XAC_NHAN_TAI_KHOAN_TRONG_TAI','XAC_NHAN_DANG_KY_GIAI')),
  CONSTRAINT chk_ycxn_trangthai
    CHECK (trangthai IN ('CHO_DUYET','DA_DUYET','TU_CHOI','DA_HUY')),
  CONSTRAINT chk_ycxn_ngayxuly
    CHECK (ngayxuly IS NULL OR ngayxuly >= ngaygui)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Yeucaucapnhathoso (
  idyeucaucapnhat     INT PRIMARY KEY AUTO_INCREMENT,
  idnguoidung         INT NOT NULL,
  banglienquan        VARCHAR(100) NOT NULL,
  truongcapnhat       VARCHAR(100) NOT NULL,
  giatricu            VARCHAR(1000) NULL,
  giatrimoi           VARCHAR(1000) NOT NULL,
  lydo                VARCHAR(1000) NULL,
  trangthai           VARCHAR(50) NOT NULL DEFAULT 'CHO_DUYET',
  ngaygui             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ngayxuly            DATETIME NULL,

  CONSTRAINT fk_yccnhs_nguoidung
    FOREIGN KEY (idnguoidung) REFERENCES Nguoidung(idnguoidung)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT chk_yccnhs_trangthai
    CHECK (trangthai IN ('CHO_DUYET','DA_DUYET','TU_CHOI')),
  CONSTRAINT chk_yccnhs_ngayxuly
    CHECK (ngayxuly IS NULL OR ngayxuly >= ngaygui)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Thongbao (
  idthongbao          INT PRIMARY KEY AUTO_INCREMENT,
  idnguoinhan         INT NOT NULL,
  tieude              VARCHAR(300) NOT NULL,
  noidung             VARCHAR(1000) NOT NULL,
  loai                VARCHAR(100) NOT NULL,
  trangthai           VARCHAR(50) NOT NULL DEFAULT 'CHUA_DOC',
  ngaytao             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ngaydoc             DATETIME NULL,

  CONSTRAINT fk_thongbao_taikhoan
    FOREIGN KEY (idnguoinhan) REFERENCES Taikhoan(idtaikhoan)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT chk_thongbao_loai
    CHECK (loai IN ('HE_THONG','XAC_NHAN','LICH_THI_DAU','KET_QUA','LOI_MOI_DOI_BONG','KHIEU_NAI')),
  CONSTRAINT chk_thongbao_trangthai
    CHECK (trangthai IN ('CHUA_DOC','DA_DOC','DA_XOA')),
  CONSTRAINT chk_thongbao_ngaydoc
    CHECK (ngaydoc IS NULL OR ngaydoc >= ngaytao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Nhatkyhethong (
  idnhatky            INT PRIMARY KEY AUTO_INCREMENT,
  idtaikhoan          INT NULL,
  hanhdong            VARCHAR(300) NOT NULL,
  bangtacdong         VARCHAR(100) NOT NULL,
  iddoituong          INT NULL,
  thoigian            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ipaddress           VARCHAR(100) NULL,
  ghichu              VARCHAR(1000) NULL,

  CONSTRAINT fk_nkht_taikhoan
    FOREIGN KEY (idtaikhoan) REFERENCES Taikhoan(idtaikhoan)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Nhatkytrangthai (
  idnhatkytrangthai   INT PRIMARY KEY AUTO_INCREMENT,
  loaidoituong        VARCHAR(100) NOT NULL,
  iddoituong          INT NOT NULL,
  trangthaicu         VARCHAR(100) NULL,
  trangthaimoi        VARCHAR(100) NOT NULL,
  lydo                VARCHAR(1000) NULL,
  idnguoithuchien     INT NULL,
  thoigian            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_nktt_taikhoan
    FOREIGN KEY (idnguoithuchien) REFERENCES Taikhoan(idtaikhoan)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT chk_nktt_loaidoituong
    CHECK (loaidoituong IN ('TAI_KHOAN','GIAI_DAU','DOI_BONG','SAN_DAU','TRAN_DAU','DANG_KY_GIAI','KHIEU_NAI','YEU_CAU_XAC_NHAN'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- IV. Nhom giai dau va doi bong
-- ============================================================

CREATE TABLE Giaidau (
  idgiaidau           INT PRIMARY KEY AUTO_INCREMENT,
  tengiaidau          VARCHAR(300) NOT NULL,
  mota                VARCHAR(1000) NULL,
  thoigianbatdau      DATE NOT NULL,
  thoigianketthuc     DATE NOT NULL,
  diadiem             VARCHAR(500) NOT NULL,
  quymo               INT NOT NULL,
  hinhanh             VARCHAR(500) NULL,
  trangthai           VARCHAR(50) NOT NULL DEFAULT 'CHUA_CONG_BO',
  trangthaidangky     VARCHAR(50) NOT NULL DEFAULT 'CHUA_MO',
  idbantochuc         INT NOT NULL,
  ngaytao             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ngaycapnhat         DATETIME NULL,

  CONSTRAINT fk_giaidau_btc
    FOREIGN KEY (idbantochuc) REFERENCES Bantochuc(idbantochuc)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT uq_giaidau_ten_thoigian
    UNIQUE (tengiaidau, thoigianbatdau),
  CONSTRAINT chk_giaidau_thoigian
    CHECK (thoigianketthuc >= thoigianbatdau),
  CONSTRAINT chk_giaidau_quymo
    CHECK (quymo > 0),
  CONSTRAINT chk_giaidau_trangthai
    CHECK (trangthai IN ('CHUA_CONG_BO','DA_CONG_BO','DANG_DIEN_RA','DA_KET_THUC','DA_HUY')),
  CONSTRAINT chk_giaidau_dangky
    CHECK (trangthaidangky IN ('CHUA_MO','DANG_MO','DA_DONG'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Dieulegiaidau (
  iddieule            INT PRIMARY KEY AUTO_INCREMENT,
  idgiaidau           INT NOT NULL,
  tieude              VARCHAR(300) NOT NULL,
  noidung             VARCHAR(3000) NOT NULL,
  filedinhkem         VARCHAR(500) NULL,
  ngaytao             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_dieule_giaidau
    FOREIGN KEY (idgiaidau) REFERENCES Giaidau(idgiaidau)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT uq_dieule_tieude
    UNIQUE (idgiaidau, tieude)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Doibong (
  iddoibong           INT PRIMARY KEY AUTO_INCREMENT,
  tendoibong          VARCHAR(300) NOT NULL,
  logo                VARCHAR(500) NULL,
  diaphuong           VARCHAR(300) NULL,
  mota                VARCHAR(1000) NULL,
  idhuanluyenvien     INT NOT NULL,
  trangthai           VARCHAR(50) NOT NULL DEFAULT 'CHO_DUYET',
  ngaytao             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ngaycapnhat         DATETIME NULL,

  CONSTRAINT fk_doibong_hlv
    FOREIGN KEY (idhuanluyenvien) REFERENCES Huanluyenvien(idhuanluyenvien)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT uq_doibong_ten
    UNIQUE (tendoibong),
  CONSTRAINT chk_doibong_trangthai
    CHECK (trangthai IN ('HOAT_DONG','CHO_DUYET','TAM_KHOA','GIAI_THE'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Dangkygiaidau (
  iddangky            INT PRIMARY KEY AUTO_INCREMENT,
  idgiaidau           INT NOT NULL,
  iddoibong           INT NOT NULL,
  idhuanluyenvien     INT NOT NULL,
  ngaydangky          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  trangthai           VARCHAR(50) NOT NULL DEFAULT 'CHO_DUYET',
  lydotuchoi          VARCHAR(1000) NULL,

  CONSTRAINT fk_dkgd_giaidau
    FOREIGN KEY (idgiaidau) REFERENCES Giaidau(idgiaidau)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_dkgd_doibong
    FOREIGN KEY (iddoibong) REFERENCES Doibong(iddoibong)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_dkgd_hlv
    FOREIGN KEY (idhuanluyenvien) REFERENCES Huanluyenvien(idhuanluyenvien)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT uq_dkgd_doi
    UNIQUE (idgiaidau, iddoibong),
  CONSTRAINT chk_dkgd_trangthai
    CHECK (trangthai IN ('CHO_DUYET','DA_DUYET','TU_CHOI','DA_HUY')),
  CONSTRAINT chk_dkgd_lydotuchoi
    CHECK ((trangthai <> 'TU_CHOI') OR (lydotuchoi IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Thanhviendoibong (
  idthanhvien         INT PRIMARY KEY AUTO_INCREMENT,
  iddoibong           INT NOT NULL,
  idvandongvien       INT NOT NULL,
  vaitro              VARCHAR(100) NOT NULL DEFAULT 'THANH_VIEN',
  trangthai           VARCHAR(50) NOT NULL DEFAULT 'CHO_XAC_NHAN',
  ngaythamgia         DATE NOT NULL,
  ngayroi             DATE NULL,

  CONSTRAINT fk_tvdb_doibong
    FOREIGN KEY (iddoibong) REFERENCES Doibong(iddoibong)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_tvdb_vdv
    FOREIGN KEY (idvandongvien) REFERENCES Vandongvien(idvandongvien)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT uq_tvdb_doi_vdv
    UNIQUE (iddoibong, idvandongvien),
  CONSTRAINT chk_tvdb_vaitro
    CHECK (vaitro IN ('DOI_TRUONG','THANH_VIEN','DU_BI')),
  CONSTRAINT chk_tvdb_trangthai
    CHECK (trangthai IN ('CHO_XAC_NHAN','DANG_THAM_GIA','DA_ROI_DOI','BI_LOAI')),
  CONSTRAINT chk_tvdb_ngayroi
    CHECK (ngayroi IS NULL OR ngayroi >= ngaythamgia)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Loimoidoibong (
  idloimoi            INT PRIMARY KEY AUTO_INCREMENT,
  iddoibong           INT NOT NULL,
  idvandongvien       INT NOT NULL,
  idhuanluyenvien     INT NOT NULL,
  noidung             VARCHAR(1000) NULL,
  trangthai           VARCHAR(50) NOT NULL DEFAULT 'CHO_PHAN_HOI',
  ngaygui             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ngayphanhoi         DATETIME NULL,
  ngayhethan          DATETIME NOT NULL,

  CONSTRAINT fk_lmdb_doibong
    FOREIGN KEY (iddoibong) REFERENCES Doibong(iddoibong)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_lmdb_vdv
    FOREIGN KEY (idvandongvien) REFERENCES Vandongvien(idvandongvien)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_lmdb_hlv
    FOREIGN KEY (idhuanluyenvien) REFERENCES Huanluyenvien(idhuanluyenvien)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT uq_lmdb_mo
    UNIQUE (iddoibong, idvandongvien, trangthai),
  CONSTRAINT chk_lmdb_trangthai
    CHECK (trangthai IN ('CHO_PHAN_HOI','DONG_Y','TU_CHOI','HET_HAN')),
  CONSTRAINT chk_lmdb_han
    CHECK (ngayhethan >= ngaygui),
  CONSTRAINT chk_lmdb_phanhoi
    CHECK (ngayphanhoi IS NULL OR ngayphanhoi >= ngaygui)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Lichsuthanhviendoibong (
  idlichsu            INT PRIMARY KEY AUTO_INCREMENT,
  idthanhvien         INT NOT NULL,
  hanhdong            VARCHAR(100) NOT NULL,
  ghichu              VARCHAR(1000) NULL,
  ngaythuchien        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  idnguoithuchien     INT NULL,

  CONSTRAINT fk_lstvdb_thanhvien
    FOREIGN KEY (idthanhvien) REFERENCES Thanhviendoibong(idthanhvien)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_lstvdb_taikhoan
    FOREIGN KEY (idnguoithuchien) REFERENCES Taikhoan(idtaikhoan)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT chk_lstvdb_hanhdong
    CHECK (hanhdong IN ('THEM_THANH_VIEN','XOA_THANH_VIEN','CHUYEN_DOI_THANH_VIEN','CAP_NHAT_VAI_TRO'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- VI. Nhom bang dau, san dau, lich thi dau
-- ============================================================

CREATE TABLE Bangdau (
  idbangdau           INT PRIMARY KEY AUTO_INCREMENT,
  idgiaidau           INT NOT NULL,
  tenbang             VARCHAR(100) NOT NULL,
  mota                VARCHAR(500) NULL,
  trangthai           VARCHAR(50) NOT NULL DEFAULT 'HOAT_DONG',
  ngaytao             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_bangdau_giaidau
    FOREIGN KEY (idgiaidau) REFERENCES Giaidau(idgiaidau)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT uq_bangdau_ten
    UNIQUE (idgiaidau, tenbang),
  CONSTRAINT chk_bangdau_trangthai
    CHECK (trangthai IN ('HOAT_DONG','DA_XOA','DA_KHOA'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Doitrongbang (
  iddoitrongbang      INT PRIMARY KEY AUTO_INCREMENT,
  idbangdau           INT NOT NULL,
  iddoibong           INT NOT NULL,
  ngaythem            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_dtb_bangdau
    FOREIGN KEY (idbangdau) REFERENCES Bangdau(idbangdau)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_dtb_doibong
    FOREIGN KEY (iddoibong) REFERENCES Doibong(iddoibong)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT uq_dtb
    UNIQUE (idbangdau, iddoibong)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Sandau (
  idsandau            INT PRIMARY KEY AUTO_INCREMENT,
  tensandau           VARCHAR(300) NOT NULL,
  diachi              VARCHAR(500) NOT NULL,
  succhua             INT NOT NULL DEFAULT 0,
  mota                VARCHAR(1000) NULL,
  trangthai           VARCHAR(50) NOT NULL DEFAULT 'HOAT_DONG',
  ngaytao             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ngaycapnhat         DATETIME NULL,

  CONSTRAINT uq_sandau_ten_diachi
    UNIQUE (tensandau, diachi),
  CONSTRAINT chk_sandau_succhua
    CHECK (succhua >= 0),
  CONSTRAINT chk_sandau_trangthai
    CHECK (trangthai IN ('HOAT_DONG','DANG_BAO_TRI','NGUNG_SU_DUNG'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Trandau (
  idtrandau           INT PRIMARY KEY AUTO_INCREMENT,
  idgiaidau           INT NOT NULL,
  idbangdau           INT NULL,
  iddoibong1          INT NOT NULL,
  iddoibong2          INT NOT NULL,
  idsandau            INT NOT NULL,
  thoigianbatdau      DATETIME NOT NULL,
  thoigianketthuc     DATETIME NULL,
  vongdau             VARCHAR(100) NOT NULL,
  trangthai           VARCHAR(50) NOT NULL DEFAULT 'CHUA_DIEN_RA',
  ngaytao             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ngaycapnhat         DATETIME NULL,

  CONSTRAINT fk_trandau_giaidau
    FOREIGN KEY (idgiaidau) REFERENCES Giaidau(idgiaidau)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_trandau_bangdau
    FOREIGN KEY (idbangdau) REFERENCES Bangdau(idbangdau)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_trandau_doi1
    FOREIGN KEY (iddoibong1) REFERENCES Doibong(iddoibong)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_trandau_doi2
    FOREIGN KEY (iddoibong2) REFERENCES Doibong(iddoibong)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_trandau_sandau
    FOREIGN KEY (idsandau) REFERENCES Sandau(idsandau)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_trandau_2doi
    CHECK (iddoibong1 <> iddoibong2),
  CONSTRAINT chk_trandau_thoigian
    CHECK (thoigianketthuc IS NULL OR thoigianketthuc > thoigianbatdau),
  CONSTRAINT chk_trandau_trangthai
    CHECK (trangthai IN ('CHUA_DIEN_RA','SAP_DIEN_RA','DANG_DIEN_RA','TAM_DUNG','DA_KET_THUC','DA_HUY'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- VII. Nhom trong tai va giam sat tran dau
-- ============================================================

CREATE TABLE Phancongtrongtai (
  idphancong          INT PRIMARY KEY AUTO_INCREMENT,
  idtrandau           INT NOT NULL,
  idtrongtai          INT NOT NULL,
  vaitro              VARCHAR(100) NOT NULL,
  trangthai           VARCHAR(50) NOT NULL DEFAULT 'CHO_XAC_NHAN',
  ngayphancong        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_pctt_trandau
    FOREIGN KEY (idtrandau) REFERENCES Trandau(idtrandau)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_pctt_trongtai
    FOREIGN KEY (idtrongtai) REFERENCES Trongtai(idtrongtai)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT uq_pctt
    UNIQUE (idtrandau, idtrongtai),
  CONSTRAINT chk_pctt_vaitro
    CHECK (vaitro IN ('TRONG_TAI_CHINH','TRONG_TAI_PHU','GIAM_SAT')),
  CONSTRAINT chk_pctt_trangthai
    CHECK (trangthai IN ('CHO_XAC_NHAN','DA_XAC_NHAN','TU_CHOI','DA_HUY'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Trongtaitrandau (
  idtrongtaitrandau   INT PRIMARY KEY AUTO_INCREMENT,
  idtrandau           INT NOT NULL,
  idtrongtai          INT NOT NULL,
  vaitro              VARCHAR(100) NOT NULL,
  xacnhanthamgia      BOOLEAN NOT NULL DEFAULT FALSE,
  thoigianxacnhan     DATETIME NULL,

  CONSTRAINT fk_tttd_trandau
    FOREIGN KEY (idtrandau) REFERENCES Trandau(idtrandau)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_tttd_trongtai
    FOREIGN KEY (idtrongtai) REFERENCES Trongtai(idtrongtai)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT uq_tttd
    UNIQUE (idtrandau, idtrongtai),
  CONSTRAINT chk_tttd_vaitro
    CHECK (vaitro IN ('TRONG_TAI_CHINH','TRONG_TAI_PHU','GIAM_SAT')),
  CONSTRAINT chk_tttd_xacnhan
    CHECK ((xacnhanthamgia = FALSE AND thoigianxacnhan IS NULL) OR (xacnhanthamgia = TRUE AND thoigianxacnhan IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Sukientrandau (
  idsukien            INT PRIMARY KEY AUTO_INCREMENT,
  idtrandau           INT NOT NULL,
  loaisukien          VARCHAR(100) NOT NULL,
  thoigian            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  noidung             VARCHAR(1000) NOT NULL,
  idnguoitao          INT NULL,

  CONSTRAINT fk_sktd_trandau
    FOREIGN KEY (idtrandau) REFERENCES Trandau(idtrandau)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_sktd_taikhoan
    FOREIGN KEY (idnguoitao) REFERENCES Taikhoan(idtaikhoan)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT chk_sktd_loai
    CHECK (loaisukien IN ('BAT_DAU','TAM_DUNG','TIEP_TUC','KET_THUC','SU_CO','GHI_NHAN_DIEM'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Baocaosuco (
  idbaocao            INT PRIMARY KEY AUTO_INCREMENT,
  idtrandau           INT NOT NULL,
  idtrongtai          INT NOT NULL,
  tieude              VARCHAR(300) NOT NULL,
  noidung             VARCHAR(2000) NOT NULL,
  minhchung           VARCHAR(500) NULL,
  trangthai           VARCHAR(50) NOT NULL DEFAULT 'DA_GUI',
  ngaybaocao          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_bcsc_trandau
    FOREIGN KEY (idtrandau) REFERENCES Trandau(idtrandau)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_bcsc_trongtai
    FOREIGN KEY (idtrongtai) REFERENCES Trongtai(idtrongtai)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_bcsc_trangthai
    CHECK (trangthai IN ('DA_GUI','DA_TIEP_NHAN','DA_XU_LY','TU_CHOI'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Donnghitrongtai (
  iddonnghi           INT PRIMARY KEY AUTO_INCREMENT,
  idtrongtai          INT NOT NULL,
  tungay              DATE NOT NULL,
  denngay             DATE NOT NULL,
  lydo                VARCHAR(1000) NOT NULL,
  trangthai           VARCHAR(50) NOT NULL DEFAULT 'CHO_DUYET',
  ngaygui             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ngayxuly            DATETIME NULL,

  CONSTRAINT fk_dntt_trongtai
    FOREIGN KEY (idtrongtai) REFERENCES Trongtai(idtrongtai)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT chk_dntt_ngay
    CHECK (denngay >= tungay),
  CONSTRAINT chk_dntt_xuly
    CHECK (ngayxuly IS NULL OR ngayxuly >= ngaygui),
  CONSTRAINT chk_dntt_trangthai
    CHECK (trangthai IN ('CHO_DUYET','DA_DUYET','TU_CHOI','DA_HUY'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- VIII. Nhom ket qua, set dau, thong ke
-- ============================================================

CREATE TABLE Ketquatrandau (
  idketqua            INT PRIMARY KEY AUTO_INCREMENT,
  idtrandau           INT NOT NULL UNIQUE,
  iddoithang          INT NULL,
  diemdoi1            INT NOT NULL DEFAULT 0,
  diemdoi2            INT NOT NULL DEFAULT 0,
  sosetdoi1           INT NOT NULL DEFAULT 0,
  sosetdoi2           INT NOT NULL DEFAULT 0,
  trangthai           VARCHAR(50) NOT NULL DEFAULT 'CHO_CONG_BO',
  ngayghinhan         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ngaycongbo          DATETIME NULL,
  idnguoighinhan      INT NULL,

  CONSTRAINT fk_kqtd_trandau
    FOREIGN KEY (idtrandau) REFERENCES Trandau(idtrandau)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_kqtd_doithang
    FOREIGN KEY (iddoithang) REFERENCES Doibong(iddoibong)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_kqtd_nguoighinhan
    FOREIGN KEY (idnguoighinhan) REFERENCES Taikhoan(idtaikhoan)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT chk_kqtd_diem
    CHECK (diemdoi1 >= 0 AND diemdoi2 >= 0 AND sosetdoi1 >= 0 AND sosetdoi2 >= 0),
  CONSTRAINT chk_kqtd_set
    CHECK (sosetdoi1 <= 5 AND sosetdoi2 <= 5),
  CONSTRAINT chk_kqtd_trangthai
    CHECK (trangthai IN ('CHO_CONG_BO','DA_CONG_BO','DA_DIEU_CHINH','BI_HUY')),
  CONSTRAINT chk_kqtd_congbo
    CHECK (ngaycongbo IS NULL OR ngaycongbo >= ngayghinhan)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Diemset (
  iddiemset           INT PRIMARY KEY AUTO_INCREMENT,
  idketqua            INT NOT NULL,
  setthu              INT NOT NULL,
  diemdoi1            INT NOT NULL DEFAULT 0,
  diemdoi2            INT NOT NULL DEFAULT 0,
  doithangset         INT NOT NULL,

  CONSTRAINT fk_diemset_ketqua
    FOREIGN KEY (idketqua) REFERENCES Ketquatrandau(idketqua)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_diemset_doithang
    FOREIGN KEY (doithangset) REFERENCES Doibong(iddoibong)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT uq_diemset
    UNIQUE (idketqua, setthu),
  CONSTRAINT chk_diemset_setthu
    CHECK (setthu BETWEEN 1 AND 5),
  CONSTRAINT chk_diemset_diem
    CHECK (diemdoi1 >= 0 AND diemdoi2 >= 0 AND diemdoi1 <> diemdoi2)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Dieuchinhketqua (
  iddieuchinh         INT PRIMARY KEY AUTO_INCREMENT,
  idketqua            INT NOT NULL,
  diemcu              VARCHAR(500) NOT NULL,
  diemmoi             VARCHAR(500) NOT NULL,
  lydo                VARCHAR(1000) NOT NULL,
  minhchung           VARCHAR(500) NULL,
  idnguoichinhsua     INT NULL,
  ngaychinhsua        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_dckq_ketqua
    FOREIGN KEY (idketqua) REFERENCES Ketquatrandau(idketqua)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_dckq_taikhoan
    FOREIGN KEY (idnguoichinhsua) REFERENCES Taikhoan(idtaikhoan)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Thongkedoi (
  idthongkedoi        INT PRIMARY KEY AUTO_INCREMENT,
  idgiaidau           INT NOT NULL,
  iddoibong           INT NOT NULL,
  sotran              INT NOT NULL DEFAULT 0,
  sotranthang         INT NOT NULL DEFAULT 0,
  sotranthua          INT NOT NULL DEFAULT 0,
  sosetthang          INT NOT NULL DEFAULT 0,
  sosetthua           INT NOT NULL DEFAULT 0,
  diem                INT NOT NULL DEFAULT 0,

  CONSTRAINT fk_tkd_giaidau
    FOREIGN KEY (idgiaidau) REFERENCES Giaidau(idgiaidau)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_tkd_doibong
    FOREIGN KEY (iddoibong) REFERENCES Doibong(iddoibong)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT uq_tkd
    UNIQUE (idgiaidau, iddoibong),
  CONSTRAINT chk_tkd_nonnegative
    CHECK (sotran >= 0 AND sotranthang >= 0 AND sotranthua >= 0 AND sosetthang >= 0 AND sosetthua >= 0 AND diem >= 0),
  CONSTRAINT chk_tkd_tongtran
    CHECK (sotran >= sotranthang + sotranthua)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Thongkecanhan (
  idthongkecanhan     INT PRIMARY KEY AUTO_INCREMENT,
  idvandongvien       INT NOT NULL,
  idgiaidau           INT NOT NULL,
  idtrandau           INT NOT NULL,
  sodiem              INT NOT NULL DEFAULT 0,
  solanphatbong       INT NOT NULL DEFAULT 0,
  solanchanbong       INT NOT NULL DEFAULT 0,
  solanghidiem        INT NOT NULL DEFAULT 0,
  ghichu              VARCHAR(1000) NULL,

  CONSTRAINT fk_tkcn_vdv
    FOREIGN KEY (idvandongvien) REFERENCES Vandongvien(idvandongvien)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_tkcn_giaidau
    FOREIGN KEY (idgiaidau) REFERENCES Giaidau(idgiaidau)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_tkcn_trandau
    FOREIGN KEY (idtrandau) REFERENCES Trandau(idtrandau)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT uq_tkcn
    UNIQUE (idvandongvien, idgiaidau, idtrandau),
  CONSTRAINT chk_tkcn_nonnegative
    CHECK (sodiem >= 0 AND solanphatbong >= 0 AND solanchanbong >= 0 AND solanghidiem >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- IX. Nhom bang xep hang
-- ============================================================

CREATE TABLE Bangxephang (
  idbangxephang       INT PRIMARY KEY AUTO_INCREMENT,
  idgiaidau           INT NOT NULL,
  tenbangxephang      VARCHAR(300) NOT NULL,
  trangthai           VARCHAR(50) NOT NULL DEFAULT 'BAN_NHAP',
  ngaytao             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ngaycongbo          DATETIME NULL,

  CONSTRAINT fk_bxh_giaidau
    FOREIGN KEY (idgiaidau) REFERENCES Giaidau(idgiaidau)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT uq_bxh
    UNIQUE (idgiaidau, tenbangxephang),
  CONSTRAINT chk_bxh_trangthai
    CHECK (trangthai IN ('BAN_NHAP','DA_CONG_BO','DA_CAP_NHAT')),
  CONSTRAINT chk_bxh_ngaycongbo
    CHECK (ngaycongbo IS NULL OR ngaycongbo >= ngaytao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Chitietbangxephang (
  idchitietbxh        INT PRIMARY KEY AUTO_INCREMENT,
  idbangxephang       INT NOT NULL,
  iddoibong           INT NOT NULL,
  hang                INT NOT NULL,
  sotran              INT NOT NULL DEFAULT 0,
  thang               INT NOT NULL DEFAULT 0,
  thua                INT NOT NULL DEFAULT 0,
  sosetthang          INT NOT NULL DEFAULT 0,
  sosetthua           INT NOT NULL DEFAULT 0,
  diem                INT NOT NULL DEFAULT 0,

  CONSTRAINT fk_ctbxh_bxh
    FOREIGN KEY (idbangxephang) REFERENCES Bangxephang(idbangxephang)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_ctbxh_doibong
    FOREIGN KEY (iddoibong) REFERENCES Doibong(iddoibong)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT uq_ctbxh_doi
    UNIQUE (idbangxephang, iddoibong),
  CONSTRAINT uq_ctbxh_hang
    UNIQUE (idbangxephang, hang),
  CONSTRAINT chk_ctbxh_hang
    CHECK (hang > 0),
  CONSTRAINT chk_ctbxh_nonnegative
    CHECK (sotran >= 0 AND thang >= 0 AND thua >= 0 AND sosetthang >= 0 AND sosetthua >= 0 AND diem >= 0),
  CONSTRAINT chk_ctbxh_tongtran
    CHECK (sotran >= thang + thua)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- X. Nhom doi hinh
-- ============================================================

CREATE TABLE Doihinh (
  iddoihinh           INT PRIMARY KEY AUTO_INCREMENT,
  iddoibong           INT NOT NULL,
  idgiaidau           INT NOT NULL,
  tendoihinh          VARCHAR(300) NOT NULL,
  trangthai           VARCHAR(50) NOT NULL DEFAULT 'BAN_NHAP',
  ngaytao             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ngaycapnhat         DATETIME NULL,

  CONSTRAINT fk_doihinh_doibong
    FOREIGN KEY (iddoibong) REFERENCES Doibong(iddoibong)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_doihinh_giaidau
    FOREIGN KEY (idgiaidau) REFERENCES Giaidau(idgiaidau)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT uq_doihinh
    UNIQUE (iddoibong, idgiaidau, tendoihinh),
  CONSTRAINT chk_doihinh_trangthai
    CHECK (trangthai IN ('BAN_NHAP','DA_CHOT','DA_CAP_NHAT'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Chitietdoihinh (
  idchitietdoihinh    INT PRIMARY KEY AUTO_INCREMENT,
  iddoihinh           INT NOT NULL,
  idvandongvien       INT NOT NULL,
  vitri               VARCHAR(100) NOT NULL,
  sothutu             INT NULL,
  ghichu              VARCHAR(500) NULL,

  CONSTRAINT fk_ctdh_doihinh
    FOREIGN KEY (iddoihinh) REFERENCES Doihinh(iddoihinh)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_ctdh_vdv
    FOREIGN KEY (idvandongvien) REFERENCES Vandongvien(idvandongvien)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT uq_ctdh_vdv
    UNIQUE (iddoihinh, idvandongvien),
  CONSTRAINT uq_ctdh_sothutu
    UNIQUE (iddoihinh, sothutu),
  CONSTRAINT chk_ctdh_vitri
    CHECK (vitri IN ('CHU_CONG','PHU_CONG','CHUYEN_HAI','DOI_CHUYEN','LIBERO','DOI_TRU')),
  CONSTRAINT chk_ctdh_sothutu
    CHECK (sothutu IS NULL OR sothutu > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- XI. Nhom khieu nai
-- ============================================================

CREATE TABLE Khieunai (
  idkhieunai          INT PRIMARY KEY AUTO_INCREMENT,
  idnguoigui          INT NOT NULL,
  idgiaidau           INT NOT NULL,
  idtrandau           INT NULL,
  tieude              VARCHAR(300) NOT NULL,
  noidung             VARCHAR(2000) NOT NULL,
  minhchung           VARCHAR(500) NULL,
  trangthai           VARCHAR(50) NOT NULL DEFAULT 'CHO_TIEP_NHAN',
  ngaygui             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ngayxuly            DATETIME NULL,
  idnguoixuly         INT NULL,

  CONSTRAINT fk_khieunai_nguoigui
    FOREIGN KEY (idnguoigui) REFERENCES Taikhoan(idtaikhoan)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_khieunai_giaidau
    FOREIGN KEY (idgiaidau) REFERENCES Giaidau(idgiaidau)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_khieunai_trandau
    FOREIGN KEY (idtrandau) REFERENCES Trandau(idtrandau)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_khieunai_nguoixuly
    FOREIGN KEY (idnguoixuly) REFERENCES Taikhoan(idtaikhoan)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT chk_khieunai_trangthai
    CHECK (trangthai IN ('CHO_TIEP_NHAN','DANG_XU_LY','DA_XU_LY','TU_CHOI','KHONG_XU_LY')),
  CONSTRAINT chk_khieunai_ngayxuly
    CHECK (ngayxuly IS NULL OR ngayxuly >= ngaygui)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- XII. Nhom nghi phep van dong vien
-- ============================================================

CREATE TABLE Donnghivandongvien (
  iddonnghi           INT PRIMARY KEY AUTO_INCREMENT,
  idvandongvien       INT NOT NULL,
  idtrandau           INT NULL,
  tungay              DATE NOT NULL,
  denngay             DATE NOT NULL,
  lydo                VARCHAR(1000) NOT NULL,
  trangthai           VARCHAR(50) NOT NULL DEFAULT 'CHO_DUYET',
  ngaygui             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ngayxuly            DATETIME NULL,
  idnguoixuly         INT NULL,

  CONSTRAINT fk_dnvdv_vdv
    FOREIGN KEY (idvandongvien) REFERENCES Vandongvien(idvandongvien)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_dnvdv_trandau
    FOREIGN KEY (idtrandau) REFERENCES Trandau(idtrandau)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_dnvdv_nguoixuly
    FOREIGN KEY (idnguoixuly) REFERENCES Taikhoan(idtaikhoan)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT chk_dnvdv_ngay
    CHECK (denngay >= tungay),
  CONSTRAINT chk_dnvdv_xuly
    CHECK (ngayxuly IS NULL OR ngayxuly >= ngaygui),
  CONSTRAINT chk_dnvdv_trangthai
    CHECK (trangthai IN ('CHO_DUYET','DA_DUYET','TU_CHOI','DA_HUY'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Trigger bo sung rang buoc nghiep vu kho bieu dien bang CHECK/FK
-- ============================================================

DELIMITER $$

CREATE TRIGGER trg_nguoidung_bi
BEFORE INSERT ON Nguoidung
FOR EACH ROW
BEGIN
  IF NEW.ngaysinh IS NOT NULL AND NEW.ngaysinh > CURRENT_DATE() THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ngay sinh khong duoc lon hon ngay hien tai';
  END IF;
END$$

CREATE TRIGGER trg_nguoidung_bu
BEFORE UPDATE ON Nguoidung
FOR EACH ROW
BEGIN
  IF NEW.ngaysinh IS NOT NULL AND NEW.ngaysinh > CURRENT_DATE() THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ngay sinh khong duoc lon hon ngay hien tai';
  END IF;
END$$

CREATE TRIGGER trg_trandau_bi
BEFORE INSERT ON Trandau
FOR EACH ROW
BEGIN
  DECLARE v_count INT DEFAULT 0;

  IF NEW.idbangdau IS NOT NULL THEN
    SELECT COUNT(*) INTO v_count
    FROM Bangdau
    WHERE idbangdau = NEW.idbangdau
      AND idgiaidau = NEW.idgiaidau;

    IF v_count = 0 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bang dau khong thuoc giai dau cua tran dau';
    END IF;
  END IF;

  SELECT COUNT(*) INTO v_count
  FROM Dangkygiaidau
  WHERE idgiaidau = NEW.idgiaidau
    AND iddoibong IN (NEW.iddoibong1, NEW.iddoibong2)
    AND trangthai = 'DA_DUYET';

  IF v_count <> 2 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hai doi bong phai duoc duyet trong cung giai dau';
  END IF;

  IF NEW.thoigianketthuc IS NOT NULL AND NEW.trangthai <> 'DA_HUY' THEN
    SELECT COUNT(*) INTO v_count
    FROM Trandau
    WHERE idsandau = NEW.idsandau
      AND trangthai <> 'DA_HUY'
      AND thoigianketthuc IS NOT NULL
      AND NEW.thoigianbatdau < thoigianketthuc
      AND NEW.thoigianketthuc > thoigianbatdau;

    IF v_count > 0 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'San dau bi trung lich trong khoang thoi gian nay';
    END IF;
  END IF;
END$$

CREATE TRIGGER trg_trandau_bu
BEFORE UPDATE ON Trandau
FOR EACH ROW
BEGIN
  DECLARE v_count INT DEFAULT 0;

  IF NEW.idbangdau IS NOT NULL THEN
    SELECT COUNT(*) INTO v_count
    FROM Bangdau
    WHERE idbangdau = NEW.idbangdau
      AND idgiaidau = NEW.idgiaidau;

    IF v_count = 0 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bang dau khong thuoc giai dau cua tran dau';
    END IF;
  END IF;

  SELECT COUNT(*) INTO v_count
  FROM Dangkygiaidau
  WHERE idgiaidau = NEW.idgiaidau
    AND iddoibong IN (NEW.iddoibong1, NEW.iddoibong2)
    AND trangthai = 'DA_DUYET';

  IF v_count <> 2 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Hai doi bong phai duoc duyet trong cung giai dau';
  END IF;

  IF NEW.thoigianketthuc IS NOT NULL AND NEW.trangthai <> 'DA_HUY' THEN
    SELECT COUNT(*) INTO v_count
    FROM Trandau
    WHERE idtrandau <> OLD.idtrandau
      AND idsandau = NEW.idsandau
      AND trangthai <> 'DA_HUY'
      AND thoigianketthuc IS NOT NULL
      AND NEW.thoigianbatdau < thoigianketthuc
      AND NEW.thoigianketthuc > thoigianbatdau;

    IF v_count > 0 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'San dau bi trung lich trong khoang thoi gian nay';
    END IF;
  END IF;
END$$

CREATE TRIGGER trg_ketquatrandau_bi
BEFORE INSERT ON Ketquatrandau
FOR EACH ROW
BEGIN
  DECLARE v_count INT DEFAULT 0;

  IF NEW.iddoithang IS NOT NULL THEN
    SELECT COUNT(*) INTO v_count
    FROM Trandau
    WHERE idtrandau = NEW.idtrandau
      AND NEW.iddoithang IN (iddoibong1, iddoibong2);

    IF v_count = 0 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doi thang phai la mot trong hai doi cua tran dau';
    END IF;
  END IF;
END$$

CREATE TRIGGER trg_ketquatrandau_bu
BEFORE UPDATE ON Ketquatrandau
FOR EACH ROW
BEGIN
  DECLARE v_count INT DEFAULT 0;

  IF NEW.iddoithang IS NOT NULL THEN
    SELECT COUNT(*) INTO v_count
    FROM Trandau
    WHERE idtrandau = NEW.idtrandau
      AND NEW.iddoithang IN (iddoibong1, iddoibong2);

    IF v_count = 0 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doi thang phai la mot trong hai doi cua tran dau';
    END IF;
  END IF;
END$$

CREATE TRIGGER trg_diemset_bi
BEFORE INSERT ON Diemset
FOR EACH ROW
BEGIN
  DECLARE v_count INT DEFAULT 0;

  SELECT COUNT(*) INTO v_count
  FROM Ketquatrandau kq
  JOIN Trandau td ON td.idtrandau = kq.idtrandau
  WHERE kq.idketqua = NEW.idketqua
    AND NEW.doithangset IN (td.iddoibong1, td.iddoibong2);

  IF v_count = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doi thang set phai la mot trong hai doi cua tran dau';
  END IF;
END$$

CREATE TRIGGER trg_diemset_bu
BEFORE UPDATE ON Diemset
FOR EACH ROW
BEGIN
  DECLARE v_count INT DEFAULT 0;

  SELECT COUNT(*) INTO v_count
  FROM Ketquatrandau kq
  JOIN Trandau td ON td.idtrandau = kq.idtrandau
  WHERE kq.idketqua = NEW.idketqua
    AND NEW.doithangset IN (td.iddoibong1, td.iddoibong2);

  IF v_count = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doi thang set phai la mot trong hai doi cua tran dau';
  END IF;
END$$

CREATE TRIGGER trg_chitietdoihinh_bi
BEFORE INSERT ON Chitietdoihinh
FOR EACH ROW
BEGIN
  DECLARE v_count INT DEFAULT 0;

  SELECT COUNT(*) INTO v_count
  FROM Doihinh dh
  JOIN Thanhviendoibong tv ON tv.iddoibong = dh.iddoibong
  WHERE dh.iddoihinh = NEW.iddoihinh
    AND tv.idvandongvien = NEW.idvandongvien
    AND tv.trangthai = 'DANG_THAM_GIA';

  IF v_count = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Van dong vien trong doi hinh phai la thanh vien dang tham gia cua doi bong';
  END IF;
END$$

CREATE TRIGGER trg_chitietdoihinh_bu
BEFORE UPDATE ON Chitietdoihinh
FOR EACH ROW
BEGIN
  DECLARE v_count INT DEFAULT 0;

  SELECT COUNT(*) INTO v_count
  FROM Doihinh dh
  JOIN Thanhviendoibong tv ON tv.iddoibong = dh.iddoibong
  WHERE dh.iddoihinh = NEW.iddoihinh
    AND tv.idvandongvien = NEW.idvandongvien
    AND tv.trangthai = 'DANG_THAM_GIA';

  IF v_count = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Van dong vien trong doi hinh phai la thanh vien dang tham gia cua doi bong';
  END IF;
END$$

DELIMITER ;

-- ============================================================
-- Du lieu mau
-- ============================================================

START TRANSACTION;

INSERT INTO `Role` (idrole, namerole, mota) VALUES
(1, 'ADMIN', 'Quan tri toan he thong'),
(2, 'BAN_TO_CHUC', 'Ban to chuc giai dau'),
(3, 'TRONG_TAI', 'Trong tai dieu hanh tran dau'),
(4, 'HUAN_LUYEN_VIEN', 'Huan luyen vien quan ly doi bong'),
(5, 'VAN_DONG_VIEN', 'Van dong vien tham gia thi dau'),
(6, 'KHAN_GIA', 'Khan gia theo doi tran dau, xem lich va ket qua');

INSERT INTO Taikhoan
(idtaikhoan, username, password, email, sodienthoai, idrole, trangthai, ngaytao, ngaycapnhat) VALUES
(1,  'admin01',  '$2y$10$nfUpRTw..BBpiT53u9MItOE7Zyxu4zgYMK1ifMgPgrEMAPQPv95ne',  'admin@vtms.local',  '0900000001', 1, 'HOAT_DONG', '2026-04-01 08:00:00', NULL),
(2,  'btc01',    '$2y$10$nfUpRTw..BBpiT53u9MItOE7Zyxu4zgYMK1ifMgPgrEMAPQPv95ne',    'btc@vtms.local',    '0900000002', 2, 'HOAT_DONG', '2026-04-01 08:05:00', NULL),
(3,  'tt01',     '$2y$10$nfUpRTw..BBpiT53u9MItOE7Zyxu4zgYMK1ifMgPgrEMAPQPv95ne',    'tt01@vtms.local',   '0900000003', 3, 'HOAT_DONG', '2026-04-01 08:10:00', NULL),
(4,  'tt02',     '$2y$10$nfUpRTw..BBpiT53u9MItOE7Zyxu4zgYMK1ifMgPgrEMAPQPv95ne',    'tt02@vtms.local',   '0900000004', 3, 'HOAT_DONG', '2026-04-01 08:15:00', NULL),
(5,  'hlv01',    '$2y$10$nfUpRTw..BBpiT53u9MItOE7Zyxu4zgYMK1ifMgPgrEMAPQPv95ne',    'hlv01@vtms.local',  '0900000005', 4, 'HOAT_DONG', '2026-04-01 08:20:00', NULL),
(6,  'hlv02',    '$2y$10$nfUpRTw..BBpiT53u9MItOE7Zyxu4zgYMK1ifMgPgrEMAPQPv95ne',    'hlv02@vtms.local',  '0900000006', 4, 'HOAT_DONG', '2026-04-01 08:25:00', NULL),
(7,  'vdv01',    '$2y$10$nfUpRTw..BBpiT53u9MItOE7Zyxu4zgYMK1ifMgPgrEMAPQPv95ne',    'vdv01@vtms.local',  '0900000007', 5, 'HOAT_DONG', '2026-04-01 08:30:00', NULL),
(8,  'vdv02',    '$2y$10$nfUpRTw..BBpiT53u9MItOE7Zyxu4zgYMK1ifMgPgrEMAPQPv95ne',    'vdv02@vtms.local',  '0900000008', 5, 'HOAT_DONG', '2026-04-01 08:35:00', NULL),
(9,  'vdv03',    '$2y$10$nfUpRTw..BBpiT53u9MItOE7Zyxu4zgYMK1ifMgPgrEMAPQPv95ne',    'vdv03@vtms.local',  '0900000009', 5, 'HOAT_DONG', '2026-04-01 08:40:00', NULL),
(10, 'vdv04',    '$2y$10$nfUpRTw..BBpiT53u9MItOE7Zyxu4zgYMK1ifMgPgrEMAPQPv95ne',    'vdv04@vtms.local',  '0900000010', 5, 'HOAT_DONG', '2026-04-01 08:45:00', NULL),
(11, 'vdv05',    '$2y$10$nfUpRTw..BBpiT53u9MItOE7Zyxu4zgYMK1ifMgPgrEMAPQPv95ne',    'vdv05@vtms.local',  '0900000011', 5, 'HOAT_DONG', '2026-04-01 08:50:00', NULL),
(12, 'vdv06',    '$2y$10$nfUpRTw..BBpiT53u9MItOE7Zyxu4zgYMK1ifMgPgrEMAPQPv95ne',    'vdv06@vtms.local',  '0900000012', 5, 'HOAT_DONG', '2026-04-01 08:55:00', NULL),
(13, 'khangia01', '$2y$10$nfUpRTw..BBpiT53u9MItOE7Zyxu4zgYMK1ifMgPgrEMAPQPv95ne', 'khangia@vtms.local', '0900000013', 6, 'HOAT_DONG', '2026-04-01 09:00:00', NULL);

INSERT INTO Lichsumatkhau (idlichsumatkhau, idtaikhoan, passwordold, ngaythaydoi) VALUES
(1, 1, '$2y$10$nfUpRTw..BBpiT53u9MItOE7Zyxu4zgYMK1ifMgPgrEMAPQPv95ne', '2026-04-02 10:00:00'),
(2, 5, '$2y$10$nfUpRTw..BBpiT53u9MItOE7Zyxu4zgYMK1ifMgPgrEMAPQPv95ne', '2026-04-02 10:10:00');

INSERT INTO Phiendangnhap
(idphien, idtaikhoan, token, thoigiandangnhap, thoigiandangxuat, trangthai) VALUES
(1, 1, 'token_admin_20260401_001', '2026-04-01 09:05:00', '2026-04-01 10:05:00', 'DA_DANG_XUAT'),
(2, 5, 'token_hlv01_20260401_001', '2026-04-01 09:10:00', NULL, 'DANG_HOAT_DONG'),
(3, 3, 'token_tt01_20260401_001', '2026-04-01 09:15:00', '2026-04-01 11:00:00', 'DA_DANG_XUAT');

INSERT INTO Lichsudangnhap
(idlichsu, idtaikhoan, thoigian, ipaddress, thietbi, ketqua, ghichu) VALUES
(1, 1, '2026-04-01 09:05:00', '192.168.1.10', 'Chrome Windows', 'THANH_CONG', 'Dang nhap thanh cong'),
(2, 5, '2026-04-01 09:10:00', '192.168.1.11', 'Edge Windows', 'THANH_CONG', 'Dang nhap thanh cong'),
(3, 7, '2026-04-01 09:20:00', '192.168.1.12', 'Mobile Android', 'THAT_BAI', 'Sai mat khau');

INSERT INTO Nguoidung
(idnguoidung, idtaikhoan, ten, hodem, gioitinh, ngaysinh, quequan, diachi, avatar, cccd, ngaytao, ngaycapnhat) VALUES
(1, 1,  'Bao',  'Nguyen Phu',       'NAM', '2004-06-10', 'TP. Ho Chi Minh', 'Quan 12, TP. Ho Chi Minh', NULL, '079204000001', '2026-04-01 09:00:00', NULL),
(2, 2,  'Lan',  'Tran Thi My',      'NU',  '1995-03-20', 'Dong Nai',        'Thu Duc, TP. Ho Chi Minh', NULL, '079195000002', '2026-04-01 09:01:00', NULL),
(3, 3,  'Minh', 'Le Hoang',         'NAM', '1988-07-15', 'Binh Duong',      'Di An, Binh Duong', NULL, '079188000003', '2026-04-01 09:02:00', NULL),
(4, 4,  'Khoa', 'Pham Anh',         'NAM', '1990-08-18', 'Tay Ninh',        'Tan Binh, TP. Ho Chi Minh', NULL, '079190000004', '2026-04-01 09:03:00', NULL),
(5, 5,  'Son',  'Do Thanh',         'NAM', '1982-09-11', 'Ha Noi',          'Go Vap, TP. Ho Chi Minh', NULL, '079182000005', '2026-04-01 09:04:00', NULL),
(6, 6,  'Nhi',  'Nguyen Yen',       'NU',  '1987-12-22', 'Long An',         'Binh Thanh, TP. Ho Chi Minh', NULL, '079187000006', '2026-04-01 09:05:00', NULL),
(7, 7,  'An',   'Vo Gia',           'NAM', '2003-01-05', 'TP. Ho Chi Minh', 'Quan 7, TP. Ho Chi Minh', NULL, '079203000007', '2026-04-01 09:06:00', NULL),
(8, 8,  'Binh', 'Nguyen Quoc',      'NAM', '2003-02-09', 'Dong Thap',       'Thu Duc, TP. Ho Chi Minh', NULL, '079203000008', '2026-04-01 09:07:00', NULL),
(9, 9,  'Cuong','Tran Minh',        'NAM', '2002-11-12', 'Can Tho',         'Quan 10, TP. Ho Chi Minh', NULL, '079202000009', '2026-04-01 09:08:00', NULL),
(10,10, 'Dung', 'Pham Quoc',        'NAM', '2004-04-25', 'Binh Phuoc',      'Quan 5, TP. Ho Chi Minh', NULL, '079204000010', '2026-04-01 09:09:00', NULL),
(11,11, 'Hoa',  'Le Thi',           'NU',  '2003-10-30', 'Vinh Long',       'Quan 3, TP. Ho Chi Minh', NULL, '079203000011', '2026-04-01 09:10:00', NULL),
(12,12, 'Phuc', 'Hoang Van',        'NAM', '2002-05-14', 'Ben Tre',         'Quan 8, TP. Ho Chi Minh', NULL, '079202000012', '2026-04-01 09:11:00', NULL),
(13,13, 'Mai',  'Dang Thanh',       'NU',  '1998-06-02', 'TP. Ho Chi Minh', 'Phu Nhuan, TP. Ho Chi Minh', NULL, '079198000013', '2026-04-01 09:12:00', NULL);

INSERT INTO Quantrivien (idquantrivien, idnguoidung, machucvu, ghichu) VALUES
(1, 1, 'SYS_ADMIN', 'Quan tri he thong VTMS');

INSERT INTO Bantochuc (idbantochuc, idnguoidung, donvi, chucvu, trangthai) VALUES
(1, 2, 'Khoa Cong nghe thong tin IUH', 'Pho ban to chuc', 'HOAT_DONG');

INSERT INTO Trongtai (idtrongtai, idnguoidung, capbac, kinhnghiem, trangthai) VALUES
(1, 3, 'Cap thanh pho', 8, 'HOAT_DONG'),
(2, 4, 'Cap truong', 4, 'HOAT_DONG');

INSERT INTO Huanluyenvien (idhuanluyenvien, idnguoidung, bangcap, kinhnghiem, trangthai) VALUES
(1, 5, 'Chung chi HLV bong chuyen co ban', 10, 'DA_XAC_NHAN'),
(2, 6, 'Chung chi HLV bong chuyen nang cao', 7, 'DA_XAC_NHAN');

INSERT INTO Vandongvien
(idvandongvien, idnguoidung, mavandongvien, chieucao, cannang, vitri, trangthaidaugiai) VALUES
(1, 7,  'VDV001', 1.82, 75.0, 'CHU_CONG',   'DU_DIEU_KIEN'),
(2, 8,  'VDV002', 1.78, 70.0, 'CHUYEN_HAI', 'DU_DIEU_KIEN'),
(3, 9,  'VDV003', 1.85, 78.0, 'LIBERO',     'DU_DIEU_KIEN'),
(4, 10, 'VDV004', 1.80, 72.0, 'PHU_CONG',   'DU_DIEU_KIEN'),
(5, 11, 'VDV005', 1.70, 60.0, 'DOI_CHUYEN', 'DU_DIEU_KIEN'),
(6, 12, 'VDV006', 1.88, 82.0, 'DOI_TRU',    'DU_DIEU_KIEN');

INSERT INTO Yeucauxacnhan
(idyeucau, loainguoigui, idnguoigui, loainguoinhan, idnguoinhan, loaixacnhan, noidung, trangthai, ngaygui, ngayxuly, ghichu) VALUES
(1, 'HUAN_LUYEN_VIEN', 1, 'BAN_TO_CHUC', 1, 'XAC_NHAN_DANG_KY_GIAI', 'Yeu cau xac nhan doi IUH Falcons tham gia giai dau', 'DA_DUYET', '2026-04-03 08:00:00', '2026-04-03 10:00:00', 'Ho so hop le'),
(2, 'VAN_DONG_VIEN', 6, 'HUAN_LUYEN_VIEN', 2, 'XAC_NHAN_NGHI_PHEP', 'Xin nghi phep vi ly do ca nhan', 'CHO_DUYET', '2026-04-04 08:00:00', NULL, NULL);

INSERT INTO Yeucaucapnhathoso
(idyeucaucapnhat, idnguoidung, banglienquan, truongcapnhat, giatricu, giatrimoi, lydo, trangthai, ngaygui, ngayxuly) VALUES
(1, 7, 'Vandongvien', 'cannang', '74.0', '75.0', 'Cap nhat can nang moi', 'DA_DUYET', '2026-04-03 09:00:00', '2026-04-03 11:00:00');

INSERT INTO Thongbao
(idthongbao, idnguoinhan, tieude, noidung, loai, trangthai, ngaytao, ngaydoc) VALUES
(1, 5, 'Dang ky giai dau da duoc duyet', 'Doi IUH Falcons da duoc chap nhan tham gia giai dau.', 'XAC_NHAN', 'DA_DOC', '2026-04-03 10:05:00', '2026-04-03 10:10:00'),
(2, 7, 'Lich thi dau moi', 'Tran dau dau tien se dien ra ngay 2026-05-11.', 'LICH_THI_DAU', 'CHUA_DOC', '2026-04-05 08:00:00', NULL);

INSERT INTO Nhatkyhethong
(idnhatky, idtaikhoan, hanhdong, bangtacdong, iddoituong, thoigian, ipaddress, ghichu) VALUES
(1, 1, 'Tao giai dau', 'Giaidau', 1, '2026-04-02 08:00:00', '192.168.1.10', 'Admin tao giai dau mau'),
(2, 2, 'Duyet dang ky doi bong', 'Dangkygiaidau', 1, '2026-04-03 10:00:00', '192.168.1.20', 'Ban to chuc duyet dang ky');

INSERT INTO Nhatkytrangthai
(idnhatkytrangthai, loaidoituong, iddoituong, trangthaicu, trangthaimoi, lydo, idnguoithuchien, thoigian) VALUES
(1, 'GIAI_DAU', 1, 'CHUA_CONG_BO', 'DA_CONG_BO', 'Cong bo giai dau', 1, '2026-04-02 08:10:00'),
(2, 'DOI_BONG', 1, 'CHO_DUYET', 'HOAT_DONG', 'Doi bong du dieu kien', 2, '2026-04-03 10:00:00');

INSERT INTO Giaidau
(idgiaidau, tengiaidau, mota, thoigianbatdau, thoigianketthuc, diadiem, quymo, hinhanh, trangthai, trangthaidangky, idbantochuc, ngaytao, ngaycapnhat) VALUES
(1, 'Giai bong chuyen IUH 2026', 'Giai dau bong chuyen sinh vien IUH nam 2026', '2026-05-10', '2026-05-20', 'Nha thi dau IUH', 8, NULL, 'DA_CONG_BO', 'DANG_MO', 1, '2026-04-02 08:00:00', NULL);

INSERT INTO Dieulegiaidau
(iddieule, idgiaidau, tieude, noidung, filedinhkem, ngaytao) VALUES
(1, 1, 'The thuc thi dau', 'Cac doi thi dau vong bang, sau do chon doi vao vong loai truc tiep.', NULL, '2026-04-02 08:30:00'),
(2, 1, 'Quy dinh van dong vien', 'Van dong vien phai co trong danh sach da duoc xac nhan truoc ngay khai mac.', NULL, '2026-04-02 08:35:00');

INSERT INTO Doibong
(iddoibong, tendoibong, logo, diaphuong, mota, idhuanluyenvien, trangthai, ngaytao, ngaycapnhat) VALUES
(1, 'IUH Falcons', NULL, 'TP. Ho Chi Minh', 'Doi bong khoa He thong thong tin', 1, 'HOAT_DONG', '2026-04-03 08:00:00', NULL),
(2, 'IUH Tigers',  NULL, 'TP. Ho Chi Minh', 'Doi bong khoa Ky thuat phan mem', 2, 'HOAT_DONG', '2026-04-03 08:05:00', NULL);

INSERT INTO Dangkygiaidau
(iddangky, idgiaidau, iddoibong, idhuanluyenvien, ngaydangky, trangthai, lydotuchoi) VALUES
(1, 1, 1, 1, '2026-04-03 08:20:00', 'DA_DUYET', NULL),
(2, 1, 2, 2, '2026-04-03 08:25:00', 'DA_DUYET', NULL);

INSERT INTO Thanhviendoibong
(idthanhvien, iddoibong, idvandongvien, vaitro, trangthai, ngaythamgia, ngayroi) VALUES
(1, 1, 1, 'DOI_TRUONG', 'DANG_THAM_GIA', '2026-04-03', NULL),
(2, 1, 2, 'THANH_VIEN', 'DANG_THAM_GIA', '2026-04-03', NULL),
(3, 1, 3, 'DU_BI',      'DANG_THAM_GIA', '2026-04-03', NULL),
(4, 2, 4, 'DOI_TRUONG', 'DANG_THAM_GIA', '2026-04-03', NULL),
(5, 2, 5, 'THANH_VIEN', 'DANG_THAM_GIA', '2026-04-03', NULL),
(6, 2, 6, 'DU_BI',      'DANG_THAM_GIA', '2026-04-03', NULL);

INSERT INTO Loimoidoibong
(idloimoi, iddoibong, idvandongvien, idhuanluyenvien, noidung, trangthai, ngaygui, ngayphanhoi, ngayhethan) VALUES
(1, 1, 1, 1, 'Moi tham gia doi IUH Falcons', 'DONG_Y', '2026-04-02 09:00:00', '2026-04-02 10:00:00', '2026-04-09 09:00:00'),
(2, 2, 4, 2, 'Moi tham gia doi IUH Tigers',  'DONG_Y', '2026-04-02 09:05:00', '2026-04-02 10:05:00', '2026-04-09 09:05:00');

INSERT INTO Lichsuthanhviendoibong
(idlichsu, idthanhvien, hanhdong, ghichu, ngaythuchien, idnguoithuchien) VALUES
(1, 1, 'THEM_THANH_VIEN', 'Them doi truong vao IUH Falcons', '2026-04-03 08:30:00', 5),
(2, 4, 'THEM_THANH_VIEN', 'Them doi truong vao IUH Tigers',  '2026-04-03 08:35:00', 6);

INSERT INTO Bangdau
(idbangdau, idgiaidau, tenbang, mota, trangthai, ngaytao) VALUES
(1, 1, 'Bang A', 'Bang dau gom IUH Falcons va IUH Tigers', 'HOAT_DONG', '2026-04-04 08:00:00');

INSERT INTO Doitrongbang
(iddoitrongbang, idbangdau, iddoibong, ngaythem) VALUES
(1, 1, 1, '2026-04-04 08:10:00'),
(2, 1, 2, '2026-04-04 08:15:00');

INSERT INTO Sandau
(idsandau, tensandau, diachi, succhua, mota, trangthai, ngaytao, ngaycapnhat) VALUES
(1, 'San A - Nha thi dau IUH', '12 Nguyen Van Bao, Go Vap, TP. Ho Chi Minh', 500, 'San thi dau chinh', 'HOAT_DONG', '2026-04-04 09:00:00', NULL),
(2, 'San B - Nha thi dau IUH', '12 Nguyen Van Bao, Go Vap, TP. Ho Chi Minh', 300, 'San thi dau phu', 'HOAT_DONG', '2026-04-04 09:05:00', NULL);

INSERT INTO Trandau
(idtrandau, idgiaidau, idbangdau, iddoibong1, iddoibong2, idsandau, thoigianbatdau, thoigianketthuc, vongdau, trangthai, ngaytao, ngaycapnhat) VALUES
(1, 1, 1, 1, 2, 1, '2026-05-11 08:00:00', '2026-05-11 09:30:00', 'Vong bang', 'DA_KET_THUC', '2026-04-05 08:00:00', NULL);

INSERT INTO Phancongtrongtai
(idphancong, idtrandau, idtrongtai, vaitro, trangthai, ngayphancong) VALUES
(1, 1, 1, 'TRONG_TAI_CHINH', 'DA_XAC_NHAN', '2026-04-05 09:00:00'),
(2, 1, 2, 'TRONG_TAI_PHU',   'DA_XAC_NHAN', '2026-04-05 09:05:00');

INSERT INTO Trongtaitrandau
(idtrongtaitrandau, idtrandau, idtrongtai, vaitro, xacnhanthamgia, thoigianxacnhan) VALUES
(1, 1, 1, 'TRONG_TAI_CHINH', TRUE, '2026-04-05 10:00:00'),
(2, 1, 2, 'TRONG_TAI_PHU',   TRUE, '2026-04-05 10:05:00');

INSERT INTO Sukientrandau
(idsukien, idtrandau, loaisukien, thoigian, noidung, idnguoitao) VALUES
(1, 1, 'BAT_DAU',       '2026-05-11 08:00:00', 'Tran dau bat dau dung gio', 3),
(2, 1, 'GHI_NHAN_DIEM', '2026-05-11 08:20:00', 'IUH Falcons dan diem set 1', 3),
(3, 1, 'KET_THUC',      '2026-05-11 09:30:00', 'Tran dau ket thuc voi ty so 3-1', 3);

INSERT INTO Baocaosuco
(idbaocao, idtrandau, idtrongtai, tieude, noidung, minhchung, trangthai, ngaybaocao) VALUES
(1, 1, 1, 'Su co bong hong', 'Bong thi dau bi hong trong set 2 va da duoc thay the.', NULL, 'DA_XU_LY', '2026-05-11 08:45:00');

INSERT INTO Donnghitrongtai
(iddonnghi, idtrongtai, tungay, denngay, lydo, trangthai, ngaygui, ngayxuly) VALUES
(1, 2, '2026-05-15', '2026-05-16', 'Ban viec ca nhan', 'DA_DUYET', '2026-04-20 08:00:00', '2026-04-21 08:00:00');

INSERT INTO Ketquatrandau
(idketqua, idtrandau, iddoithang, diemdoi1, diemdoi2, sosetdoi1, sosetdoi2, trangthai, ngayghinhan, ngaycongbo, idnguoighinhan) VALUES
(1, 1, 1, 97, 85, 3, 1, 'DA_CONG_BO', '2026-05-11 09:35:00', '2026-05-11 10:00:00', 3);

INSERT INTO Diemset
(iddiemset, idketqua, setthu, diemdoi1, diemdoi2, doithangset) VALUES
(1, 1, 1, 25, 20, 1),
(2, 1, 2, 22, 25, 2),
(3, 1, 3, 25, 18, 1),
(4, 1, 4, 25, 22, 1);

INSERT INTO Dieuchinhketqua
(iddieuchinh, idketqua, diemcu, diemmoi, lydo, minhchung, idnguoichinhsua, ngaychinhsua) VALUES
(1, 1, 'Set 3: 25-17', 'Set 3: 25-18', 'Cap nhat lai diem theo bien ban trong tai', NULL, 3, '2026-05-11 09:50:00');

INSERT INTO Thongkedoi
(idthongkedoi, idgiaidau, iddoibong, sotran, sotranthang, sotranthua, sosetthang, sosetthua, diem) VALUES
(1, 1, 1, 1, 1, 0, 3, 1, 3),
(2, 1, 2, 1, 0, 1, 1, 3, 0);

INSERT INTO Thongkecanhan
(idthongkecanhan, idvandongvien, idgiaidau, idtrandau, sodiem, solanphatbong, solanchanbong, solanghidiem, ghichu) VALUES
(1, 1, 1, 1, 18, 12, 4, 18, 'Chu cong ghi diem cao nhat doi'),
(2, 2, 1, 1, 10, 18, 2, 10, 'Chuyen hai thi dau on dinh'),
(3, 4, 1, 1, 16, 10, 3, 16, 'Doi truong IUH Tigers');

INSERT INTO Bangxephang
(idbangxephang, idgiaidau, tenbangxephang, trangthai, ngaytao, ngaycongbo) VALUES
(1, 1, 'Bang xep hang Bang A', 'DA_CONG_BO', '2026-05-11 10:05:00', '2026-05-11 10:10:00');

INSERT INTO Chitietbangxephang
(idchitietbxh, idbangxephang, iddoibong, hang, sotran, thang, thua, sosetthang, sosetthua, diem) VALUES
(1, 1, 1, 1, 1, 1, 0, 3, 1, 3),
(2, 1, 2, 2, 1, 0, 1, 1, 3, 0);

INSERT INTO Doihinh
(iddoihinh, iddoibong, idgiaidau, tendoihinh, trangthai, ngaytao, ngaycapnhat) VALUES
(1, 1, 1, 'Doi hinh chinh IUH Falcons', 'DA_CHOT', '2026-05-10 07:00:00', NULL),
(2, 2, 1, 'Doi hinh chinh IUH Tigers',  'DA_CHOT', '2026-05-10 07:05:00', NULL);

INSERT INTO Chitietdoihinh
(idchitietdoihinh, iddoihinh, idvandongvien, vitri, sothutu, ghichu) VALUES
(1, 1, 1, 'CHU_CONG',   7,  'Doi truong'),
(2, 1, 2, 'CHUYEN_HAI', 9,  NULL),
(3, 1, 3, 'LIBERO',     11, NULL),
(4, 2, 4, 'PHU_CONG',   8,  'Doi truong'),
(5, 2, 5, 'DOI_CHUYEN', 10, NULL),
(6, 2, 6, 'DOI_TRU',    12, NULL);

INSERT INTO Khieunai
(idkhieunai, idnguoigui, idgiaidau, idtrandau, tieude, noidung, minhchung, trangthai, ngaygui, ngayxuly, idnguoixuly) VALUES
(1, 6, 1, 1, 'Khieu nai ve diem set 3', 'HLV IUH Tigers de nghi kiem tra lai diem set 3.', NULL, 'DA_XU_LY', '2026-05-11 09:40:00', '2026-05-11 09:55:00', 1);

INSERT INTO Donnghivandongvien
(iddonnghi, idvandongvien, idtrandau, tungay, denngay, lydo, trangthai, ngaygui, ngayxuly, idnguoixuly) VALUES
(1, 6, 1, '2026-05-11', '2026-05-11', 'Dau co chan nhe, xin vang mat neu khong duoc thay vao san', 'DA_DUYET', '2026-05-10 18:00:00', '2026-05-10 20:00:00', 6);

COMMIT;

-- ============================================================
-- Kiem tra nhanh so luong ban ghi trong cac bang chinh
-- ============================================================

SELECT 'Role' AS bang, COUNT(*) AS so_ban_ghi FROM `Role`
UNION ALL SELECT 'Taikhoan', COUNT(*) FROM Taikhoan
UNION ALL SELECT 'Nguoidung', COUNT(*) FROM Nguoidung
UNION ALL SELECT 'Giaidau', COUNT(*) FROM Giaidau
UNION ALL SELECT 'Doibong', COUNT(*) FROM Doibong
UNION ALL SELECT 'Trandau', COUNT(*) FROM Trandau
UNION ALL SELECT 'Ketquatrandau', COUNT(*) FROM Ketquatrandau
UNION ALL SELECT 'Bangxephang', COUNT(*) FROM Bangxephang;
