-- =========================================================
-- VTMS MIGRATION V2 STRICT - FIX AMBIGUOUS COLUMN
-- Module: Xac nhan tu cach tham gia cua doi bong
-- Fix: qualify doidudieukienthamgia.trangthai in ON DUPLICATE KEY UPDATE to avoid Error 1052.
-- Database: vtms
-- Run after: vtms_full_rebuild.sql
--
-- Muc tieu:
--  1) Bo sung cau hinh dieu kien tham gia giai bang ma chuan, khong dung text tu do cho logic.
--  2) Luu lich su thanh tich doi bong theo giai, cap giai, khu vuc, mua giai.
--  3) Luu suat tham du va danh sach doi du dieu kien tham gia giai.
--  4) Gan ho so dang ky giai voi ban ghi tu cach hop le.
--  5) Siết CHECK, FK, UNIQUE, TRIGGER de backend co du lieu sach.
--
-- Luu y:
--  - Khong DROP DATABASE, khong DROP bang loi cua he thong hien tai.
--  - File nay duoc khuyen nghi chay tren CSDL vtms moi tao tu vtms_full_rebuild.sql.
--  - Neu da chay ban migration cu truoc do, nen rebuild lai vtms roi chay file nay de tranh CHECK cu xung dot ma code moi.
-- =========================================================

USE vtms;
SET SQL_MODE = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
SET FOREIGN_KEY_CHECKS = 1;

-- =========================================================
-- 0. Helper procedures: add column/index/FK safely
-- =========================================================

DROP PROCEDURE IF EXISTS sp_vtms_add_column_if_not_exists;
DROP PROCEDURE IF EXISTS sp_vtms_add_index_if_not_exists;
DROP PROCEDURE IF EXISTS sp_vtms_add_fk_if_not_exists;

DELIMITER $$

CREATE PROCEDURE sp_vtms_add_column_if_not_exists(
    IN p_table_name VARCHAR(64),
    IN p_column_name VARCHAR(64),
    IN p_column_definition TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = p_table_name
          AND COLUMN_NAME = p_column_name
    ) THEN
        SET @sql_add_col = CONCAT('ALTER TABLE `', p_table_name, '` ADD COLUMN ', p_column_definition);
        PREPARE stmt FROM @sql_add_col;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

CREATE PROCEDURE sp_vtms_add_index_if_not_exists(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64),
    IN p_index_definition TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = p_table_name
          AND INDEX_NAME = p_index_name
    ) THEN
        SET @sql_add_idx = CONCAT('ALTER TABLE `', p_table_name, '` ADD ', p_index_definition);
        PREPARE stmt FROM @sql_add_idx;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

CREATE PROCEDURE sp_vtms_add_fk_if_not_exists(
    IN p_table_name VARCHAR(64),
    IN p_constraint_name VARCHAR(64),
    IN p_constraint_definition TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.TABLE_CONSTRAINTS
        WHERE CONSTRAINT_SCHEMA = DATABASE()
          AND TABLE_NAME = p_table_name
          AND CONSTRAINT_NAME = p_constraint_name
    ) THEN
        SET @sql_add_fk = CONCAT('ALTER TABLE `', p_table_name, '` ADD CONSTRAINT `', p_constraint_name, '` ', p_constraint_definition);
        PREPARE stmt FROM @sql_add_fk;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

DELIMITER ;

-- =========================================================
-- 1. Extend quytacchondoi with structured eligibility settings
--    Text tu do chi duoc dung o mota/ghichu, khong dung cho logic.
-- =========================================================

CALL sp_vtms_add_column_if_not_exists(
    'quytacchondoi',
    'yeu_cau_thanh_tich',
    "`yeu_cau_thanh_tich` VARCHAR(50) NOT NULL DEFAULT 'KHONG_YEU_CAU' AFTER `capdoituongthamgia`"
);

CALL sp_vtms_add_column_if_not_exists(
    'quytacchondoi',
    'idcapgiaidau_thanh_tich_nguon',
    '`idcapgiaidau_thanh_tich_nguon` INT NULL AFTER `yeu_cau_thanh_tich`'
);

CALL sp_vtms_add_column_if_not_exists(
    'quytacchondoi',
    'hang_toi_thieu_duoc_phep',
    '`hang_toi_thieu_duoc_phep` INT NULL AFTER `idcapgiaidau_thanh_tich_nguon`'
);

CALL sp_vtms_add_column_if_not_exists(
    'quytacchondoi',
    'so_mua_giai_gan_nhat_duoc_tinh',
    '`so_mua_giai_gan_nhat_duoc_tinh` INT NULL AFTER `hang_toi_thieu_duoc_phep`'
);

CALL sp_vtms_add_column_if_not_exists(
    'quytacchondoi',
    'cho_phep_btc_duyet_ngoai_le',
    '`cho_phep_btc_duyet_ngoai_le` TINYINT(1) NOT NULL DEFAULT 1 AFTER `so_mua_giai_gan_nhat_duoc_tinh`'
);

CALL sp_vtms_add_index_if_not_exists(
    'quytacchondoi',
    'idx_qtcd_capttnguon',
    'INDEX `idx_qtcd_capttnguon` (`idcapgiaidau_thanh_tich_nguon`)'
);

CALL sp_vtms_add_fk_if_not_exists(
    'quytacchondoi',
    'fk_qtcd_capgiaidau_thanh_tich_nguon_v2',
    'FOREIGN KEY (`idcapgiaidau_thanh_tich_nguon`) REFERENCES `capgiaidau`(`idcapgiaidau`) ON UPDATE CASCADE ON DELETE SET NULL'
);

-- =========================================================
-- 2. dieukienthamgiagiai
--    Cau hinh dieu kien tham gia cua tung giai.
--    Vi du: Giai QUOC_GIA yeu cau doi dai dien TINH_THANH va VO_DICH cap TINH_THANH.
-- =========================================================

CREATE TABLE IF NOT EXISTS dieukienthamgiagiai (
    iddieukienthamgia INT PRIMARY KEY AUTO_INCREMENT,
    idgiaidau INT NOT NULL,
    idquytac INT NULL,
    ten_dieukien VARCHAR(300) NOT NULL,

    capdoituongthamgia VARCHAR(50) NOT NULL,
    yeu_cau_thanh_tich VARCHAR(50) NOT NULL DEFAULT 'KHONG_YEU_CAU',
    idcapgiaidau_thanh_tich_nguon INT NULL,
    hang_toi_thieu_duoc_phep INT NULL,
    so_mua_giai_gan_nhat_duoc_tinh INT NULL,

    chi_tinh_giai_chinh_thuc TINYINT(1) NOT NULL DEFAULT 1,
    bat_buoc_cung_khuvuc TINYINT(1) NOT NULL DEFAULT 1,
    cho_phep_btc_duyet_ngoai_le TINYINT(1) NOT NULL DEFAULT 1,

    mota VARCHAR(1500) NULL,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'HOAT_DONG',
    ngaytao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngaycapnhat DATETIME NULL,

    UNIQUE KEY uq_dktg_giai_ten (idgiaidau, ten_dieukien),
    KEY idx_dktg_giai (idgiaidau),
    KEY idx_dktg_quytac (idquytac),
    KEY idx_dktg_capnguon (idcapgiaidau_thanh_tich_nguon),
    KEY idx_dktg_capdoi (capdoituongthamgia),

    CONSTRAINT fk_dktg_giaidau FOREIGN KEY (idgiaidau) REFERENCES giaidau(idgiaidau)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_dktg_quytac FOREIGN KEY (idquytac) REFERENCES quytacchondoi(idquytac)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_dktg_capnguon FOREIGN KEY (idcapgiaidau_thanh_tich_nguon) REFERENCES capgiaidau(idcapgiaidau)
        ON UPDATE CASCADE ON DELETE SET NULL,

    CONSTRAINT chk_dktg_capdoi_v2 CHECK (capdoituongthamgia IN ('TINH_THANH','QUAN_HUYEN','XA_PHUONG','DON_VI')),
    CONSTRAINT chk_dktg_yeucau_v2 CHECK (yeu_cau_thanh_tich IN (
        'KHONG_YEU_CAU',
        'VO_DICH',
        'A_QUAN',
        'HANG_BA',
        'TOP_N',
        'THEO_XEP_HANG',
        'BTC_CHON',
        'DAC_CACH'
    )),
    CONSTRAINT chk_dktg_hang_v2 CHECK (hang_toi_thieu_duoc_phep IS NULL OR hang_toi_thieu_duoc_phep >= 1),
    CONSTRAINT chk_dktg_mua_v2 CHECK (so_mua_giai_gan_nhat_duoc_tinh IS NULL OR so_mua_giai_gan_nhat_duoc_tinh >= 1),
    CONSTRAINT chk_dktg_bool_v2 CHECK (
        chi_tinh_giai_chinh_thuc IN (0,1)
        AND bat_buoc_cung_khuvuc IN (0,1)
        AND cho_phep_btc_duyet_ngoai_le IN (0,1)
    ),
    CONSTRAINT chk_dktg_trangthai_v2 CHECK (trangthai IN ('HOAT_DONG','TAM_NGUNG','NGUNG_SU_DUNG')),
    CONSTRAINT chk_dktg_req_logic_v2 CHECK (
        (yeu_cau_thanh_tich IN ('KHONG_YEU_CAU','BTC_CHON','DAC_CACH') AND idcapgiaidau_thanh_tich_nguon IS NULL)
        OR
        (yeu_cau_thanh_tich IN ('VO_DICH','A_QUAN','HANG_BA','TOP_N','THEO_XEP_HANG') AND idcapgiaidau_thanh_tich_nguon IS NOT NULL)
    ),
    CONSTRAINT chk_dktg_topn_logic_v2 CHECK (
        (yeu_cau_thanh_tich <> 'TOP_N')
        OR
        (yeu_cau_thanh_tich = 'TOP_N' AND hang_toi_thieu_duoc_phep IS NOT NULL AND hang_toi_thieu_duoc_phep >= 1)
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 3. thanhtichdoibong
--    Luu lich su thanh tich co cau truc. Hang la so, danh hieu la ma chuan.
-- =========================================================

CREATE TABLE IF NOT EXISTS thanhtichdoibong (
    idthanhtich INT PRIMARY KEY AUTO_INCREMENT,
    iddoibong INT NOT NULL,
    idgiaidau INT NOT NULL,
    idvongdau INT NULL,
    idbangxephang INT NULL,
    idchitietbxh INT NULL,

    idcapgiaidau INT NOT NULL,
    idkhuvuc INT NOT NULL,
    mua_giai INT NOT NULL,

    hang_dat_duoc INT NOT NULL,
    danhhieu VARCHAR(50) NOT NULL,
    ngay_cong_nhan DATE NOT NULL,
    nguon_ghi_nhan VARCHAR(50) NOT NULL DEFAULT 'BANG_XEP_HANG',
    ghi_chu VARCHAR(1000) NULL,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'HOP_LE',
    ngaytao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngaycapnhat DATETIME NULL,

    UNIQUE KEY uq_tt_doi_giai_danhhieu (iddoibong, idgiaidau, danhhieu),
    KEY idx_tt_doi (iddoibong),
    KEY idx_tt_giai (idgiaidau),
    KEY idx_tt_cap_hang (idcapgiaidau, hang_dat_duoc),
    KEY idx_tt_mua (mua_giai),
    KEY idx_tt_khuvuc (idkhuvuc),
    KEY idx_tt_ctbxh (idchitietbxh),

    CONSTRAINT fk_tt_doi_v2 FOREIGN KEY (iddoibong) REFERENCES doibong(iddoibong)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_tt_giai_v2 FOREIGN KEY (idgiaidau) REFERENCES giaidau(idgiaidau)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_tt_vong_v2 FOREIGN KEY (idvongdau) REFERENCES vongdau(idvongdau)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_tt_bxh_v2 FOREIGN KEY (idbangxephang) REFERENCES bangxephang(idbangxephang)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_tt_ctbxh_v2 FOREIGN KEY (idchitietbxh) REFERENCES chitietbangxephang(idchitietbxh)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_tt_cap_v2 FOREIGN KEY (idcapgiaidau) REFERENCES capgiaidau(idcapgiaidau)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_tt_khuvuc_v2 FOREIGN KEY (idkhuvuc) REFERENCES khuvuc(idkhuvuc)
        ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT chk_tt_mua_v2 CHECK (mua_giai BETWEEN 2000 AND 2100),
    CONSTRAINT chk_tt_hang_v2 CHECK (hang_dat_duoc >= 1),
    CONSTRAINT chk_tt_danhhieu_v2 CHECK (danhhieu IN ('VO_DICH','A_QUAN','HANG_BA','TOP_4','TOP_8','THAM_DU','KHAC')),
    CONSTRAINT chk_tt_nguon_v2 CHECK (nguon_ghi_nhan IN ('BANG_XEP_HANG','BTC_NHAP_TAY','HE_THONG_TONG_HOP')),
    CONSTRAINT chk_tt_trangthai_v2 CHECK (trangthai IN ('HOP_LE','BI_HUY','TAM_TREO'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 4. suatthamdu
--    Luu suat tham du tu giai/cap duoi len giai/cap tren.
-- =========================================================

CREATE TABLE IF NOT EXISTS suatthamdu (
    idsuat INT PRIMARY KEY AUTO_INCREMENT,
    idgiaidau_nguon INT NULL,
    idgiaidau_dich INT NOT NULL,
    idcapgiaidau_nguon INT NULL,
    idcapgiaidau_dich INT NOT NULL,
    idkhuvucphamvi INT NULL,
    loaisuat VARCHAR(50) NOT NULL,
    soluongsuat INT NOT NULL DEFAULT 1,
    hang_toi_thieu INT NULL,
    tieuchi_mota VARCHAR(1000) NULL,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'MO',
    ngaytao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngaycapnhat DATETIME NULL,

    KEY idx_suat_giai_nguon (idgiaidau_nguon),
    KEY idx_suat_giai_dich (idgiaidau_dich),
    KEY idx_suat_cap (idcapgiaidau_nguon, idcapgiaidau_dich),
    KEY idx_suat_khuvuc (idkhuvucphamvi),

    CONSTRAINT fk_suat_giai_nguon_v2 FOREIGN KEY (idgiaidau_nguon) REFERENCES giaidau(idgiaidau)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_suat_giai_dich_v2 FOREIGN KEY (idgiaidau_dich) REFERENCES giaidau(idgiaidau)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_suat_cap_nguon_v2 FOREIGN KEY (idcapgiaidau_nguon) REFERENCES capgiaidau(idcapgiaidau)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_suat_cap_dich_v2 FOREIGN KEY (idcapgiaidau_dich) REFERENCES capgiaidau(idcapgiaidau)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_suat_khuvuc_v2 FOREIGN KEY (idkhuvucphamvi) REFERENCES khuvuc(idkhuvuc)
        ON UPDATE CASCADE ON DELETE SET NULL,

    CONSTRAINT chk_suat_loai_v2 CHECK (loaisuat IN ('VO_DICH_CAP_DUOI','A_QUAN_CAP_DUOI','HANG_BA_CAP_DUOI','TOP_N_CAP_DUOI','XEP_HANG','BTC_CHON','DAC_CACH')),
    CONSTRAINT chk_suat_soluong_v2 CHECK (soluongsuat >= 1),
    CONSTRAINT chk_suat_hang_v2 CHECK (hang_toi_thieu IS NULL OR hang_toi_thieu >= 1),
    CONSTRAINT chk_suat_trangthai_v2 CHECK (trangthai IN ('MO','DA_SU_DUNG','HET_HAN','HUY')),
    CONSTRAINT chk_suat_topn_v2 CHECK ((loaisuat <> 'TOP_N_CAP_DUOI') OR (hang_toi_thieu IS NOT NULL AND hang_toi_thieu >= 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 5. doidudieukienthamgia
--    Ban ghi ket qua xet tu cach: doi nao du dieu kien tham gia giai nao, vi sao.
-- =========================================================

CREATE TABLE IF NOT EXISTS doidudieukienthamgia (
    iddieukien INT PRIMARY KEY AUTO_INCREMENT,
    idgiaidau INT NOT NULL,
    iddoibong INT NOT NULL,
    iddieukienthamgia INT NULL,
    idsuat INT NULL,
    idthanhtich INT NULL,
    nguon_dieukien VARCHAR(50) NOT NULL,
    lydo_dieukien VARCHAR(1000) NULL,
    diem_xet_duyet DECIMAL(10,2) NULL,
    trangthai VARCHAR(50) NOT NULL DEFAULT 'DU_DIEU_KIEN',
    ngay_xac_nhan DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    idnguoixacnhan INT NULL,
    ghichu VARCHAR(1000) NULL,

    UNIQUE KEY uq_ddk_giai_doi_v2 (idgiaidau, iddoibong),
    KEY idx_ddk_giai_v2 (idgiaidau),
    KEY idx_ddk_doi_v2 (iddoibong),
    KEY idx_ddk_dktg_v2 (iddieukienthamgia),
    KEY idx_ddk_suat_v2 (idsuat),
    KEY idx_ddk_thanhtich_v2 (idthanhtich),
    KEY idx_ddk_taikhoan_v2 (idnguoixacnhan),

    CONSTRAINT fk_ddk_giai_v2 FOREIGN KEY (idgiaidau) REFERENCES giaidau(idgiaidau)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_ddk_doi_v2 FOREIGN KEY (iddoibong) REFERENCES doibong(iddoibong)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_ddk_dktg_v2 FOREIGN KEY (iddieukienthamgia) REFERENCES dieukienthamgiagiai(iddieukienthamgia)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_ddk_suat_v2 FOREIGN KEY (idsuat) REFERENCES suatthamdu(idsuat)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_ddk_thanhtich_v2 FOREIGN KEY (idthanhtich) REFERENCES thanhtichdoibong(idthanhtich)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_ddk_taikhoan_v2 FOREIGN KEY (idnguoixacnhan) REFERENCES taikhoan(idtaikhoan)
        ON UPDATE CASCADE ON DELETE SET NULL,

    CONSTRAINT chk_ddk_nguon_v2 CHECK (nguon_dieukien IN ('THANH_TICH','XEP_HANG','SUAT_THAM_DU','BTC_CHON','DAC_CACH','DANG_KY_TU_DO')),
    CONSTRAINT chk_ddk_trangthai_v2 CHECK (trangthai IN ('DU_DIEU_KIEN','DA_MOI','DA_DANG_KY','DA_DUYET','TU_CHOI','HUY_TU_CACH','HET_HAN')),
    CONSTRAINT chk_ddk_diem_v2 CHECK (diem_xet_duyet IS NULL OR diem_xet_duyet >= 0),
    CONSTRAINT chk_ddk_source_required_v2 CHECK (
        (nguon_dieukien = 'THANH_TICH' AND idthanhtich IS NOT NULL)
        OR (nguon_dieukien = 'SUAT_THAM_DU' AND idsuat IS NOT NULL)
        OR (nguon_dieukien IN ('XEP_HANG','BTC_CHON','DAC_CACH','DANG_KY_TU_DO'))
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 6. Extend dangkygiaidau with structured eligibility link
-- =========================================================

CALL sp_vtms_add_column_if_not_exists(
    'dangkygiaidau',
    'iddieukien',
    '`iddieukien` INT NULL AFTER `idhuanluyenvien`'
);

CALL sp_vtms_add_column_if_not_exists(
    'dangkygiaidau',
    'nguon_dang_ky',
    "`nguon_dang_ky` VARCHAR(50) NOT NULL DEFAULT 'TU_DANG_KY' AFTER `iddieukien`"
);

CALL sp_vtms_add_column_if_not_exists(
    'dangkygiaidau',
    'lydo_xet_tu_cach',
    '`lydo_xet_tu_cach` VARCHAR(1000) NULL AFTER `lydotuchoi`'
);

CALL sp_vtms_add_index_if_not_exists(
    'dangkygiaidau',
    'idx_dkgd_dieukien_v2',
    'INDEX `idx_dkgd_dieukien_v2` (`iddieukien`)'
);

CALL sp_vtms_add_fk_if_not_exists(
    'dangkygiaidau',
    'fk_dkgd_dieukien_v2',
    'FOREIGN KEY (`iddieukien`) REFERENCES `doidudieukienthamgia`(`iddieukien`) ON UPDATE CASCADE ON DELETE SET NULL'
);

-- =========================================================
-- 7. Triggers: normalize and enforce all rule-bearing fields
-- =========================================================

DROP TRIGGER IF EXISTS trg_qtcd_tucach_bi_v2;
DROP TRIGGER IF EXISTS trg_qtcd_tucach_bu_v2;
DROP TRIGGER IF EXISTS trg_dieukienthamgiagiai_bi_v2;
DROP TRIGGER IF EXISTS trg_dieukienthamgiagiai_bu_v2;
DROP TRIGGER IF EXISTS trg_thanhtichdoibong_bi_v2;
DROP TRIGGER IF EXISTS trg_thanhtichdoibong_bu_v2;
DROP TRIGGER IF EXISTS trg_suatthamdu_bi_v2;
DROP TRIGGER IF EXISTS trg_suatthamdu_bu_v2;
DROP TRIGGER IF EXISTS trg_doidudieukien_bi_v2;
DROP TRIGGER IF EXISTS trg_doidudieukien_bu_v2;
DROP TRIGGER IF EXISTS trg_dkgd_dieukien_bi_v2;
DROP TRIGGER IF EXISTS trg_dkgd_dieukien_bu_v2;

DELIMITER $$

CREATE TRIGGER trg_qtcd_tucach_bi_v2
BEFORE INSERT ON quytacchondoi
FOR EACH ROW
BEGIN
    DECLARE v_capdoi VARCHAR(50);
    DECLARE v_capnguon_ma VARCHAR(50);

    SELECT cg.capdoituongthamgia INTO v_capdoi
    FROM giaidau gd
    JOIN capgiaidau cg ON cg.idcapgiaidau = gd.idcapgiaidau
    WHERE gd.idgiaidau = NEW.idgiaidau;

    IF NEW.capdoituongthamgia <> v_capdoi THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Quy tac chon doi phai khop cap doi tuong tham gia cua cap giai.';
    END IF;

    IF NEW.yeu_cau_thanh_tich NOT IN ('KHONG_YEU_CAU','VO_DICH','A_QUAN','HANG_BA','TOP_N','THEO_XEP_HANG','BTC_CHON','DAC_CACH') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'yeu_cau_thanh_tich khong nam trong bo ma chuan.';
    END IF;

    IF NEW.yeu_cau_thanh_tich IN ('VO_DICH','A_QUAN','HANG_BA','TOP_N','THEO_XEP_HANG') THEN
        IF NEW.idcapgiaidau_thanh_tich_nguon IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Yeu cau thanh tich bat buoc co cap giai thanh tich nguon.';
        END IF;
        SELECT macapgiaidau INTO v_capnguon_ma FROM capgiaidau WHERE idcapgiaidau = NEW.idcapgiaidau_thanh_tich_nguon;
        IF v_capnguon_ma <> v_capdoi THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cap giai thanh tich nguon phai khop cap doi tuong tham gia.';
        END IF;
    ELSEIF NEW.idcapgiaidau_thanh_tich_nguon IS NOT NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Khong yeu cau thanh tich thi khong duoc gan cap giai thanh tich nguon.';
    END IF;

    IF NEW.yeu_cau_thanh_tich = 'TOP_N' AND (NEW.hang_toi_thieu_duoc_phep IS NULL OR NEW.hang_toi_thieu_duoc_phep < 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'TOP_N bat buoc co hang_toi_thieu_duoc_phep >= 1.';
    END IF;

    IF NEW.hang_toi_thieu_duoc_phep IS NOT NULL AND NEW.hang_toi_thieu_duoc_phep < 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'hang_toi_thieu_duoc_phep phai >= 1.';
    END IF;

    IF NEW.so_mua_giai_gan_nhat_duoc_tinh IS NOT NULL AND NEW.so_mua_giai_gan_nhat_duoc_tinh < 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'so_mua_giai_gan_nhat_duoc_tinh phai >= 1.';
    END IF;
END$$

CREATE TRIGGER trg_qtcd_tucach_bu_v2
BEFORE UPDATE ON quytacchondoi
FOR EACH ROW
BEGIN
    DECLARE v_capdoi VARCHAR(50);
    DECLARE v_capnguon_ma VARCHAR(50);

    SELECT cg.capdoituongthamgia INTO v_capdoi
    FROM giaidau gd
    JOIN capgiaidau cg ON cg.idcapgiaidau = gd.idcapgiaidau
    WHERE gd.idgiaidau = NEW.idgiaidau;

    IF NEW.capdoituongthamgia <> v_capdoi THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Quy tac chon doi phai khop cap doi tuong tham gia cua cap giai.';
    END IF;

    IF NEW.yeu_cau_thanh_tich NOT IN ('KHONG_YEU_CAU','VO_DICH','A_QUAN','HANG_BA','TOP_N','THEO_XEP_HANG','BTC_CHON','DAC_CACH') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'yeu_cau_thanh_tich khong nam trong bo ma chuan.';
    END IF;

    IF NEW.yeu_cau_thanh_tich IN ('VO_DICH','A_QUAN','HANG_BA','TOP_N','THEO_XEP_HANG') THEN
        IF NEW.idcapgiaidau_thanh_tich_nguon IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Yeu cau thanh tich bat buoc co cap giai thanh tich nguon.';
        END IF;
        SELECT macapgiaidau INTO v_capnguon_ma FROM capgiaidau WHERE idcapgiaidau = NEW.idcapgiaidau_thanh_tich_nguon;
        IF v_capnguon_ma <> v_capdoi THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cap giai thanh tich nguon phai khop cap doi tuong tham gia.';
        END IF;
    ELSEIF NEW.idcapgiaidau_thanh_tich_nguon IS NOT NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Khong yeu cau thanh tich thi khong duoc gan cap giai thanh tich nguon.';
    END IF;

    IF NEW.yeu_cau_thanh_tich = 'TOP_N' AND (NEW.hang_toi_thieu_duoc_phep IS NULL OR NEW.hang_toi_thieu_duoc_phep < 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'TOP_N bat buoc co hang_toi_thieu_duoc_phep >= 1.';
    END IF;

    IF NEW.hang_toi_thieu_duoc_phep IS NOT NULL AND NEW.hang_toi_thieu_duoc_phep < 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'hang_toi_thieu_duoc_phep phai >= 1.';
    END IF;

    IF NEW.so_mua_giai_gan_nhat_duoc_tinh IS NOT NULL AND NEW.so_mua_giai_gan_nhat_duoc_tinh < 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'so_mua_giai_gan_nhat_duoc_tinh phai >= 1.';
    END IF;
END$$

CREATE TRIGGER trg_dieukienthamgiagiai_bi_v2
BEFORE INSERT ON dieukienthamgiagiai
FOR EACH ROW
BEGIN
    DECLARE v_capdoi VARCHAR(50);
    DECLARE v_capnguon_ma VARCHAR(50);

    SELECT cg.capdoituongthamgia INTO v_capdoi
    FROM giaidau gd
    JOIN capgiaidau cg ON cg.idcapgiaidau = gd.idcapgiaidau
    WHERE gd.idgiaidau = NEW.idgiaidau;

    IF NEW.capdoituongthamgia <> v_capdoi THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Dieu kien tham gia phai khop cap doi tuong tham gia cua cap giai.';
    END IF;

    IF NEW.idquytac IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM quytacchondoi qt WHERE qt.idquytac = NEW.idquytac AND qt.idgiaidau = NEW.idgiaidau
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Quy tac chon doi khong thuoc giai dau cua dieu kien tham gia.';
    END IF;

    IF NEW.yeu_cau_thanh_tich IN ('VO_DICH','A_QUAN','HANG_BA','TOP_N','THEO_XEP_HANG') THEN
        SELECT macapgiaidau INTO v_capnguon_ma FROM capgiaidau WHERE idcapgiaidau = NEW.idcapgiaidau_thanh_tich_nguon;
        IF v_capnguon_ma <> v_capdoi THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cap giai thanh tich nguon phai khop cap doi tuong tham gia.';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_dieukienthamgiagiai_bu_v2
BEFORE UPDATE ON dieukienthamgiagiai
FOR EACH ROW
BEGIN
    DECLARE v_capdoi VARCHAR(50);
    DECLARE v_capnguon_ma VARCHAR(50);

    SELECT cg.capdoituongthamgia INTO v_capdoi
    FROM giaidau gd
    JOIN capgiaidau cg ON cg.idcapgiaidau = gd.idcapgiaidau
    WHERE gd.idgiaidau = NEW.idgiaidau;

    IF NEW.capdoituongthamgia <> v_capdoi THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Dieu kien tham gia phai khop cap doi tuong tham gia cua cap giai.';
    END IF;

    IF NEW.idquytac IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM quytacchondoi qt WHERE qt.idquytac = NEW.idquytac AND qt.idgiaidau = NEW.idgiaidau
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Quy tac chon doi khong thuoc giai dau cua dieu kien tham gia.';
    END IF;

    IF NEW.yeu_cau_thanh_tich IN ('VO_DICH','A_QUAN','HANG_BA','TOP_N','THEO_XEP_HANG') THEN
        SELECT macapgiaidau INTO v_capnguon_ma FROM capgiaidau WHERE idcapgiaidau = NEW.idcapgiaidau_thanh_tich_nguon;
        IF v_capnguon_ma <> v_capdoi THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cap giai thanh tich nguon phai khop cap doi tuong tham gia.';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_thanhtichdoibong_bi_v2
BEFORE INSERT ON thanhtichdoibong
FOR EACH ROW
BEGIN
    DECLARE v_cap_giai INT;
    DECLARE v_khuvuc_giai INT;
    DECLARE v_vong_giai INT;
    DECLARE v_bxh_giai INT;
    DECLARE v_ct_doi INT;
    DECLARE v_ct_hang INT;
    DECLARE v_ct_giai INT;

    SELECT idcapgiaidau, idkhuvucphamvi INTO v_cap_giai, v_khuvuc_giai
    FROM giaidau WHERE idgiaidau = NEW.idgiaidau;

    IF NEW.idcapgiaidau <> v_cap_giai THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Thanh tich phai khop cap giai dau nguon.';
    END IF;
    IF NEW.idkhuvuc <> v_khuvuc_giai THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Thanh tich phai khop khu vuc/pham vi cua giai dau nguon.';
    END IF;

    IF NEW.idvongdau IS NOT NULL THEN
        SELECT idgiaidau INTO v_vong_giai FROM vongdau WHERE idvongdau = NEW.idvongdau;
        IF v_vong_giai <> NEW.idgiaidau THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vong dau cua thanh tich khong thuoc giai dau nguon.';
        END IF;
    END IF;

    IF NEW.idbangxephang IS NOT NULL THEN
        SELECT idgiaidau INTO v_bxh_giai FROM bangxephang WHERE idbangxephang = NEW.idbangxephang;
        IF v_bxh_giai <> NEW.idgiaidau THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bang xep hang cua thanh tich khong thuoc giai dau nguon.';
        END IF;
    END IF;

    IF NEW.idchitietbxh IS NOT NULL THEN
        SELECT ct.iddoibong, ct.hang, bx.idgiaidau INTO v_ct_doi, v_ct_hang, v_ct_giai
        FROM chitietbangxephang ct
        JOIN bangxephang bx ON bx.idbangxephang = ct.idbangxephang
        WHERE ct.idchitietbxh = NEW.idchitietbxh;

        IF v_ct_doi <> NEW.iddoibong OR v_ct_giai <> NEW.idgiaidau OR v_ct_hang <> NEW.hang_dat_duoc THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Chi tiet BXH khong khop doi/giai/hang cua thanh tich.';
        END IF;
    END IF;

    IF (NEW.hang_dat_duoc = 1 AND NEW.danhhieu <> 'VO_DICH')
       OR (NEW.hang_dat_duoc = 2 AND NEW.danhhieu <> 'A_QUAN')
       OR (NEW.hang_dat_duoc = 3 AND NEW.danhhieu <> 'HANG_BA')
       OR (NEW.danhhieu = 'TOP_4' AND NEW.hang_dat_duoc > 4)
       OR (NEW.danhhieu = 'TOP_8' AND NEW.hang_dat_duoc > 8) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Danh hieu khong khop voi thu hang dat duoc.';
    END IF;
END$$

CREATE TRIGGER trg_thanhtichdoibong_bu_v2
BEFORE UPDATE ON thanhtichdoibong
FOR EACH ROW
BEGIN
    DECLARE v_cap_giai INT;
    DECLARE v_khuvuc_giai INT;
    DECLARE v_vong_giai INT;
    DECLARE v_bxh_giai INT;
    DECLARE v_ct_doi INT;
    DECLARE v_ct_hang INT;
    DECLARE v_ct_giai INT;

    SELECT idcapgiaidau, idkhuvucphamvi INTO v_cap_giai, v_khuvuc_giai
    FROM giaidau WHERE idgiaidau = NEW.idgiaidau;

    IF NEW.idcapgiaidau <> v_cap_giai THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Thanh tich phai khop cap giai dau nguon.';
    END IF;
    IF NEW.idkhuvuc <> v_khuvuc_giai THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Thanh tich phai khop khu vuc/pham vi cua giai dau nguon.';
    END IF;

    IF NEW.idvongdau IS NOT NULL THEN
        SELECT idgiaidau INTO v_vong_giai FROM vongdau WHERE idvongdau = NEW.idvongdau;
        IF v_vong_giai <> NEW.idgiaidau THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vong dau cua thanh tich khong thuoc giai dau nguon.';
        END IF;
    END IF;

    IF NEW.idbangxephang IS NOT NULL THEN
        SELECT idgiaidau INTO v_bxh_giai FROM bangxephang WHERE idbangxephang = NEW.idbangxephang;
        IF v_bxh_giai <> NEW.idgiaidau THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bang xep hang cua thanh tich khong thuoc giai dau nguon.';
        END IF;
    END IF;

    IF NEW.idchitietbxh IS NOT NULL THEN
        SELECT ct.iddoibong, ct.hang, bx.idgiaidau INTO v_ct_doi, v_ct_hang, v_ct_giai
        FROM chitietbangxephang ct
        JOIN bangxephang bx ON bx.idbangxephang = ct.idbangxephang
        WHERE ct.idchitietbxh = NEW.idchitietbxh;

        IF v_ct_doi <> NEW.iddoibong OR v_ct_giai <> NEW.idgiaidau OR v_ct_hang <> NEW.hang_dat_duoc THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Chi tiet BXH khong khop doi/giai/hang cua thanh tich.';
        END IF;
    END IF;

    IF (NEW.hang_dat_duoc = 1 AND NEW.danhhieu <> 'VO_DICH')
       OR (NEW.hang_dat_duoc = 2 AND NEW.danhhieu <> 'A_QUAN')
       OR (NEW.hang_dat_duoc = 3 AND NEW.danhhieu <> 'HANG_BA')
       OR (NEW.danhhieu = 'TOP_4' AND NEW.hang_dat_duoc > 4)
       OR (NEW.danhhieu = 'TOP_8' AND NEW.hang_dat_duoc > 8) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Danh hieu khong khop voi thu hang dat duoc.';
    END IF;
END$$

CREATE TRIGGER trg_suatthamdu_bi_v2
BEFORE INSERT ON suatthamdu
FOR EACH ROW
BEGIN
    DECLARE v_cap_nguon INT;
    DECLARE v_cap_dich INT;

    IF NEW.idgiaidau_nguon IS NOT NULL THEN
        SELECT idcapgiaidau INTO v_cap_nguon FROM giaidau WHERE idgiaidau = NEW.idgiaidau_nguon;
        IF NEW.idcapgiaidau_nguon IS NOT NULL AND NEW.idcapgiaidau_nguon <> v_cap_nguon THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cap giai nguon cua suat tham du khong khop giai nguon.';
        END IF;
    END IF;

    SELECT idcapgiaidau INTO v_cap_dich FROM giaidau WHERE idgiaidau = NEW.idgiaidau_dich;
    IF NEW.idcapgiaidau_dich <> v_cap_dich THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cap giai dich cua suat tham du khong khop giai dich.';
    END IF;

    IF NEW.loaisuat IN ('VO_DICH_CAP_DUOI','A_QUAN_CAP_DUOI','HANG_BA_CAP_DUOI','TOP_N_CAP_DUOI') AND NEW.idcapgiaidau_nguon IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Suat thanh tich cap duoi phai co idcapgiaidau_nguon.';
    END IF;
END$$

CREATE TRIGGER trg_suatthamdu_bu_v2
BEFORE UPDATE ON suatthamdu
FOR EACH ROW
BEGIN
    DECLARE v_cap_nguon INT;
    DECLARE v_cap_dich INT;

    IF NEW.idgiaidau_nguon IS NOT NULL THEN
        SELECT idcapgiaidau INTO v_cap_nguon FROM giaidau WHERE idgiaidau = NEW.idgiaidau_nguon;
        IF NEW.idcapgiaidau_nguon IS NOT NULL AND NEW.idcapgiaidau_nguon <> v_cap_nguon THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cap giai nguon cua suat tham du khong khop giai nguon.';
        END IF;
    END IF;

    SELECT idcapgiaidau INTO v_cap_dich FROM giaidau WHERE idgiaidau = NEW.idgiaidau_dich;
    IF NEW.idcapgiaidau_dich <> v_cap_dich THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cap giai dich cua suat tham du khong khop giai dich.';
    END IF;

    IF NEW.loaisuat IN ('VO_DICH_CAP_DUOI','A_QUAN_CAP_DUOI','HANG_BA_CAP_DUOI','TOP_N_CAP_DUOI') AND NEW.idcapgiaidau_nguon IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Suat thanh tich cap duoi phai co idcapgiaidau_nguon.';
    END IF;
END$$

CREATE TRIGGER trg_doidudieukien_bi_v2
BEFORE INSERT ON doidudieukienthamgia
FOR EACH ROW
BEGIN
    DECLARE v_giai_khuvuc INT;
    DECLARE v_cap_doi_yeucau VARCHAR(50);
    DECLARE v_doi_khuvuc INT;
    DECLARE v_doi_cap VARCHAR(50);
    DECLARE v_doi_status VARCHAR(50);
    DECLARE v_req VARCHAR(50);
    DECLARE v_capnguon INT;
    DECLARE v_hangmax INT;
    DECLARE v_dktg_giai INT;
    DECLARE v_tt_doi INT;
    DECLARE v_tt_giai INT;
    DECLARE v_tt_cap INT;
    DECLARE v_tt_hang INT;
    DECLARE v_tt_status VARCHAR(50);
    DECLARE v_suat_giai INT;

    SELECT g.idkhuvucphamvi, cg.capdoituongthamgia INTO v_giai_khuvuc, v_cap_doi_yeucau
    FROM giaidau g
    JOIN capgiaidau cg ON cg.idcapgiaidau = g.idcapgiaidau
    WHERE g.idgiaidau = NEW.idgiaidau;

    SELECT db.idkhuvucdaidien, kv.capkhuvuc, db.trangthai INTO v_doi_khuvuc, v_doi_cap, v_doi_status
    FROM doibong db
    JOIN khuvuc kv ON kv.idkhuvuc = db.idkhuvucdaidien
    WHERE db.iddoibong = NEW.iddoibong;

    IF v_doi_status <> 'HOAT_DONG' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Chi doi bong HOAT_DONG moi duoc xet tu cach tham gia.';
    END IF;

    IF NEW.iddieukienthamgia IS NOT NULL THEN
        SELECT idgiaidau, capdoituongthamgia, yeu_cau_thanh_tich, idcapgiaidau_thanh_tich_nguon, hang_toi_thieu_duoc_phep
        INTO v_dktg_giai, v_cap_doi_yeucau, v_req, v_capnguon, v_hangmax
        FROM dieukienthamgiagiai
        WHERE iddieukienthamgia = NEW.iddieukienthamgia;
        IF v_dktg_giai <> NEW.idgiaidau THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Dieu kien tham gia khong thuoc giai dau dang xet.';
        END IF;
    ELSE
        SET v_req = 'KHONG_YEU_CAU';
        SET v_capnguon = NULL;
        SET v_hangmax = NULL;
    END IF;

    IF v_doi_cap <> v_cap_doi_yeucau THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doi bong khong dung cap doi tuong tham gia cua giai.';
    END IF;

    IF v_doi_khuvuc <> v_giai_khuvuc AND fn_khuvuc_la_con(v_doi_khuvuc, v_giai_khuvuc) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doi bong khong nam trong pham vi khu vuc cua giai.';
    END IF;

    IF NEW.nguon_dieukien = 'THANH_TICH' THEN
        IF NEW.idthanhtich IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nguon THANH_TICH bat buoc co idthanhtich.';
        END IF;
        SELECT iddoibong, idgiaidau, idcapgiaidau, hang_dat_duoc, trangthai
        INTO v_tt_doi, v_tt_giai, v_tt_cap, v_tt_hang, v_tt_status
        FROM thanhtichdoibong
        WHERE idthanhtich = NEW.idthanhtich;
        IF v_tt_doi <> NEW.iddoibong THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Thanh tich khong thuoc doi bong dang xet.';
        END IF;
        IF v_tt_status <> 'HOP_LE' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Thanh tich khong o trang thai hop le.';
        END IF;
        IF v_capnguon IS NOT NULL AND v_tt_cap <> v_capnguon THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Thanh tich khong dung cap giai nguon yeu cau.';
        END IF;
        IF v_req = 'VO_DICH' AND v_tt_hang <> 1 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Dieu kien VO_DICH yeu cau hang_dat_duoc = 1.';
        END IF;
        IF v_req = 'A_QUAN' AND v_tt_hang <> 2 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Dieu kien A_QUAN yeu cau hang_dat_duoc = 2.';
        END IF;
        IF v_req = 'HANG_BA' AND v_tt_hang <> 3 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Dieu kien HANG_BA yeu cau hang_dat_duoc = 3.';
        END IF;
        IF v_req IN ('TOP_N','THEO_XEP_HANG') AND v_hangmax IS NOT NULL AND v_tt_hang > v_hangmax THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Thu hang thanh tich khong dat dieu kien tham gia.';
        END IF;
    END IF;

    IF NEW.nguon_dieukien = 'SUAT_THAM_DU' THEN
        IF NEW.idsuat IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nguon SUAT_THAM_DU bat buoc co idsuat.';
        END IF;
        SELECT idgiaidau_dich INTO v_suat_giai FROM suatthamdu WHERE idsuat = NEW.idsuat;
        IF v_suat_giai <> NEW.idgiaidau THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Suat tham du khong thuoc giai dau dich dang xet.';
        END IF;
    END IF;

    IF NEW.nguon_dieukien IN ('BTC_CHON','DAC_CACH') THEN
        IF NEW.lydo_dieukien IS NULL OR LENGTH(TRIM(NEW.lydo_dieukien)) = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BTC_CHON/DAC_CACH bat buoc co lydo_dieukien.';
        END IF;
        IF NEW.idnguoixacnhan IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BTC_CHON/DAC_CACH bat buoc co idnguoixacnhan.';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_doidudieukien_bu_v2
BEFORE UPDATE ON doidudieukienthamgia
FOR EACH ROW
BEGIN
    DECLARE v_giai_khuvuc INT;
    DECLARE v_cap_doi_yeucau VARCHAR(50);
    DECLARE v_doi_khuvuc INT;
    DECLARE v_doi_cap VARCHAR(50);
    DECLARE v_doi_status VARCHAR(50);
    DECLARE v_req VARCHAR(50);
    DECLARE v_capnguon INT;
    DECLARE v_hangmax INT;
    DECLARE v_dktg_giai INT;
    DECLARE v_tt_doi INT;
    DECLARE v_tt_giai INT;
    DECLARE v_tt_cap INT;
    DECLARE v_tt_hang INT;
    DECLARE v_tt_status VARCHAR(50);
    DECLARE v_suat_giai INT;

    SELECT g.idkhuvucphamvi, cg.capdoituongthamgia INTO v_giai_khuvuc, v_cap_doi_yeucau
    FROM giaidau g
    JOIN capgiaidau cg ON cg.idcapgiaidau = g.idcapgiaidau
    WHERE g.idgiaidau = NEW.idgiaidau;

    SELECT db.idkhuvucdaidien, kv.capkhuvuc, db.trangthai INTO v_doi_khuvuc, v_doi_cap, v_doi_status
    FROM doibong db
    JOIN khuvuc kv ON kv.idkhuvuc = db.idkhuvucdaidien
    WHERE db.iddoibong = NEW.iddoibong;

    IF v_doi_status <> 'HOAT_DONG' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Chi doi bong HOAT_DONG moi duoc xet tu cach tham gia.';
    END IF;

    IF NEW.iddieukienthamgia IS NOT NULL THEN
        SELECT idgiaidau, capdoituongthamgia, yeu_cau_thanh_tich, idcapgiaidau_thanh_tich_nguon, hang_toi_thieu_duoc_phep
        INTO v_dktg_giai, v_cap_doi_yeucau, v_req, v_capnguon, v_hangmax
        FROM dieukienthamgiagiai
        WHERE iddieukienthamgia = NEW.iddieukienthamgia;
        IF v_dktg_giai <> NEW.idgiaidau THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Dieu kien tham gia khong thuoc giai dau dang xet.';
        END IF;
    ELSE
        SET v_req = 'KHONG_YEU_CAU';
        SET v_capnguon = NULL;
        SET v_hangmax = NULL;
    END IF;

    IF v_doi_cap <> v_cap_doi_yeucau THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doi bong khong dung cap doi tuong tham gia cua giai.';
    END IF;

    IF v_doi_khuvuc <> v_giai_khuvuc AND fn_khuvuc_la_con(v_doi_khuvuc, v_giai_khuvuc) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doi bong khong nam trong pham vi khu vuc cua giai.';
    END IF;

    IF NEW.nguon_dieukien = 'THANH_TICH' THEN
        IF NEW.idthanhtich IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nguon THANH_TICH bat buoc co idthanhtich.';
        END IF;
        SELECT iddoibong, idgiaidau, idcapgiaidau, hang_dat_duoc, trangthai
        INTO v_tt_doi, v_tt_giai, v_tt_cap, v_tt_hang, v_tt_status
        FROM thanhtichdoibong
        WHERE idthanhtich = NEW.idthanhtich;
        IF v_tt_doi <> NEW.iddoibong THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Thanh tich khong thuoc doi bong dang xet.';
        END IF;
        IF v_tt_status <> 'HOP_LE' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Thanh tich khong o trang thai hop le.';
        END IF;
        IF v_capnguon IS NOT NULL AND v_tt_cap <> v_capnguon THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Thanh tich khong dung cap giai nguon yeu cau.';
        END IF;
        IF v_req = 'VO_DICH' AND v_tt_hang <> 1 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Dieu kien VO_DICH yeu cau hang_dat_duoc = 1.';
        END IF;
        IF v_req = 'A_QUAN' AND v_tt_hang <> 2 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Dieu kien A_QUAN yeu cau hang_dat_duoc = 2.';
        END IF;
        IF v_req = 'HANG_BA' AND v_tt_hang <> 3 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Dieu kien HANG_BA yeu cau hang_dat_duoc = 3.';
        END IF;
        IF v_req IN ('TOP_N','THEO_XEP_HANG') AND v_hangmax IS NOT NULL AND v_tt_hang > v_hangmax THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Thu hang thanh tich khong dat dieu kien tham gia.';
        END IF;
    END IF;

    IF NEW.nguon_dieukien = 'SUAT_THAM_DU' THEN
        IF NEW.idsuat IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nguon SUAT_THAM_DU bat buoc co idsuat.';
        END IF;
        SELECT idgiaidau_dich INTO v_suat_giai FROM suatthamdu WHERE idsuat = NEW.idsuat;
        IF v_suat_giai <> NEW.idgiaidau THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Suat tham du khong thuoc giai dau dich dang xet.';
        END IF;
    END IF;

    IF NEW.nguon_dieukien IN ('BTC_CHON','DAC_CACH') THEN
        IF NEW.lydo_dieukien IS NULL OR LENGTH(TRIM(NEW.lydo_dieukien)) = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BTC_CHON/DAC_CACH bat buoc co lydo_dieukien.';
        END IF;
        IF NEW.idnguoixacnhan IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'BTC_CHON/DAC_CACH bat buoc co idnguoixacnhan.';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_dkgd_dieukien_bi_v2
BEFORE INSERT ON dangkygiaidau
FOR EACH ROW
BEGIN
    DECLARE v_giai INT;
    DECLARE v_doi INT;
    DECLARE v_status VARCHAR(50);

    IF NEW.nguon_dang_ky NOT IN ('TU_DANG_KY','DUOC_MOI','BTC_THEM','HE_THONG_DE_XUAT') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'nguon_dang_ky khong nam trong bo ma chuan.';
    END IF;

    IF NEW.iddieukien IS NOT NULL THEN
        SELECT idgiaidau, iddoibong, trangthai INTO v_giai, v_doi, v_status
        FROM doidudieukienthamgia
        WHERE iddieukien = NEW.iddieukien;
        IF v_giai <> NEW.idgiaidau OR v_doi <> NEW.iddoibong THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Dieu kien tham gia khong khop voi ho so dang ky.';
        END IF;
        IF v_status IN ('TU_CHOI','HUY_TU_CACH','HET_HAN') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doi bong khong co tu cach hop le de dang ky giai.';
        END IF;
    ELSE
        IF NEW.nguon_dang_ky IN ('DUOC_MOI','HE_THONG_DE_XUAT') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Dang ky DUOC_MOI/HE_THONG_DE_XUAT phai gan iddieukien.';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_dkgd_dieukien_bu_v2
BEFORE UPDATE ON dangkygiaidau
FOR EACH ROW
BEGIN
    DECLARE v_giai INT;
    DECLARE v_doi INT;
    DECLARE v_status VARCHAR(50);

    IF NEW.nguon_dang_ky NOT IN ('TU_DANG_KY','DUOC_MOI','BTC_THEM','HE_THONG_DE_XUAT') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'nguon_dang_ky khong nam trong bo ma chuan.';
    END IF;

    IF NEW.iddieukien IS NOT NULL THEN
        SELECT idgiaidau, iddoibong, trangthai INTO v_giai, v_doi, v_status
        FROM doidudieukienthamgia
        WHERE iddieukien = NEW.iddieukien;
        IF v_giai <> NEW.idgiaidau OR v_doi <> NEW.iddoibong THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Dieu kien tham gia khong khop voi ho so dang ky.';
        END IF;
        IF v_status IN ('TU_CHOI','HUY_TU_CACH','HET_HAN') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doi bong khong co tu cach hop le de dang ky giai.';
        END IF;
    ELSE
        IF NEW.nguon_dang_ky IN ('DUOC_MOI','HE_THONG_DE_XUAT') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Dang ky DUOC_MOI/HE_THONG_DE_XUAT phai gan iddieukien.';
        END IF;
    END IF;
END$$

DELIMITER ;

-- =========================================================
-- 8. Procedure: generate eligible teams from achievement conditions
-- =========================================================

DROP PROCEDURE IF EXISTS sp_tao_doi_du_dieu_kien_tu_thanhtich_v2;

DELIMITER $$

CREATE PROCEDURE sp_tao_doi_du_dieu_kien_tu_thanhtich_v2(IN p_idgiaidau INT)
BEGIN
    INSERT INTO doidudieukienthamgia (
        idgiaidau,
        iddoibong,
        iddieukienthamgia,
        idthanhtich,
        nguon_dieukien,
        lydo_dieukien,
        diem_xet_duyet,
        trangthai,
        ngay_xac_nhan
    )
    SELECT
        dk.idgiaidau,
        tt.iddoibong,
        dk.iddieukienthamgia,
        tt.idthanhtich,
        'THANH_TICH',
        CONCAT('Dat hang ', tt.hang_dat_duoc, ' tai ', gnguon.tengiaidau, ' mua ', tt.mua_giai),
        db.diem_xep_hang,
        'DU_DIEU_KIEN',
        NOW()
    FROM dieukienthamgiagiai dk
    JOIN giaidau gdich ON gdich.idgiaidau = dk.idgiaidau
    JOIN thanhtichdoibong tt ON tt.trangthai = 'HOP_LE'
    JOIN giaidau gnguon ON gnguon.idgiaidau = tt.idgiaidau
    JOIN doibong db ON db.iddoibong = tt.iddoibong AND db.trangthai = 'HOAT_DONG'
    JOIN khuvuc kvdoi ON kvdoi.idkhuvuc = db.idkhuvucdaidien
    WHERE dk.idgiaidau = p_idgiaidau
      AND dk.trangthai = 'HOAT_DONG'
      AND dk.yeu_cau_thanh_tich IN ('VO_DICH','A_QUAN','HANG_BA','TOP_N','THEO_XEP_HANG')
      AND kvdoi.capkhuvuc = dk.capdoituongthamgia
      AND (db.idkhuvucdaidien = gdich.idkhuvucphamvi OR fn_khuvuc_la_con(db.idkhuvucdaidien, gdich.idkhuvucphamvi) = 1)
      AND tt.idcapgiaidau = dk.idcapgiaidau_thanh_tich_nguon
      AND (
          (dk.yeu_cau_thanh_tich = 'VO_DICH' AND tt.hang_dat_duoc = 1)
          OR (dk.yeu_cau_thanh_tich = 'A_QUAN' AND tt.hang_dat_duoc = 2)
          OR (dk.yeu_cau_thanh_tich = 'HANG_BA' AND tt.hang_dat_duoc = 3)
          OR (dk.yeu_cau_thanh_tich IN ('TOP_N','THEO_XEP_HANG') AND tt.hang_dat_duoc <= dk.hang_toi_thieu_duoc_phep)
      )
    ON DUPLICATE KEY UPDATE
        iddieukienthamgia = VALUES(iddieukienthamgia),
        idthanhtich = VALUES(idthanhtich),
        nguon_dieukien = VALUES(nguon_dieukien),
        lydo_dieukien = VALUES(lydo_dieukien),
        diem_xet_duyet = VALUES(diem_xet_duyet),
        trangthai = IF(doidudieukienthamgia.trangthai IN ('TU_CHOI','HUY_TU_CACH'), doidudieukienthamgia.trangthai, VALUES(trangthai)),
        ngay_xac_nhan = VALUES(ngay_xac_nhan);
END$$

DELIMITER ;

-- Backward-friendly alias for backend if it already calls the old name.
DROP PROCEDURE IF EXISTS sp_tao_doi_du_dieu_kien_tu_thanhtich;
DELIMITER $$
CREATE PROCEDURE sp_tao_doi_du_dieu_kien_tu_thanhtich(IN p_idgiaidau INT)
BEGIN
    CALL sp_tao_doi_du_dieu_kien_tu_thanhtich_v2(p_idgiaidau);
END$$
DELIMITER ;

-- =========================================================
-- 9. Views for UI/backend
-- =========================================================

CREATE OR REPLACE VIEW vw_thanhtich_doibong AS
SELECT
    tt.idthanhtich,
    tt.iddoibong,
    db.tendoibong,
    tt.idgiaidau,
    gd.tengiaidau,
    cg.macapgiaidau,
    cg.tencapgiaidau,
    kv.tenkhuvuc,
    tt.mua_giai,
    tt.hang_dat_duoc,
    tt.danhhieu,
    tt.nguon_ghi_nhan,
    tt.ngay_cong_nhan,
    tt.trangthai
FROM thanhtichdoibong tt
JOIN doibong db ON db.iddoibong = tt.iddoibong
JOIN giaidau gd ON gd.idgiaidau = tt.idgiaidau
JOIN capgiaidau cg ON cg.idcapgiaidau = tt.idcapgiaidau
JOIN khuvuc kv ON kv.idkhuvuc = tt.idkhuvuc;

CREATE OR REPLACE VIEW vw_dieu_kien_tham_gia_giai AS
SELECT
    dk.iddieukienthamgia,
    dk.idgiaidau,
    gd.tengiaidau,
    dk.ten_dieukien,
    dk.capdoituongthamgia,
    dk.yeu_cau_thanh_tich,
    cgn.macapgiaidau AS capgiaidau_thanh_tich_nguon,
    dk.hang_toi_thieu_duoc_phep,
    dk.so_mua_giai_gan_nhat_duoc_tinh,
    dk.cho_phep_btc_duyet_ngoai_le,
    dk.trangthai
FROM dieukienthamgiagiai dk
JOIN giaidau gd ON gd.idgiaidau = dk.idgiaidau
LEFT JOIN capgiaidau cgn ON cgn.idcapgiaidau = dk.idcapgiaidau_thanh_tich_nguon;

CREATE OR REPLACE VIEW vw_doi_du_dieu_kien_tham_gia AS
SELECT
    ddk.iddieukien,
    ddk.idgiaidau,
    gd.tengiaidau,
    ddk.iddoibong,
    db.tendoibong,
    kv.tenkhuvuc AS khuvuc_daidien,
    kv.capkhuvuc AS cap_daidien,
    ddk.nguon_dieukien,
    ddk.lydo_dieukien,
    ddk.trangthai,
    ddk.idthanhtich,
    tt.hang_dat_duoc,
    tt.danhhieu,
    tt.mua_giai,
    ddk.idsuat
FROM doidudieukienthamgia ddk
JOIN giaidau gd ON gd.idgiaidau = ddk.idgiaidau
JOIN doibong db ON db.iddoibong = ddk.iddoibong
JOIN khuvuc kv ON kv.idkhuvuc = db.idkhuvucdaidien
LEFT JOIN thanhtichdoibong tt ON tt.idthanhtich = ddk.idthanhtich;

CREATE OR REPLACE VIEW vw_goi_y_doi_du_dieu_kien_theo_thanh_tich AS
SELECT
    dk.iddieukienthamgia,
    dk.idgiaidau AS idgiaidau_dich,
    gdich.tengiaidau AS tengiaidau_dich,
    tt.iddoibong,
    db.tendoibong,
    tt.idthanhtich,
    gnguon.tengiaidau AS giai_dat_thanh_tich,
    tt.hang_dat_duoc,
    tt.danhhieu,
    tt.mua_giai,
    dk.yeu_cau_thanh_tich,
    dk.hang_toi_thieu_duoc_phep,
    kvdoi.tenkhuvuc AS khuvuc_daidien
FROM dieukienthamgiagiai dk
JOIN giaidau gdich ON gdich.idgiaidau = dk.idgiaidau
JOIN thanhtichdoibong tt ON tt.trangthai = 'HOP_LE'
JOIN giaidau gnguon ON gnguon.idgiaidau = tt.idgiaidau
JOIN doibong db ON db.iddoibong = tt.iddoibong AND db.trangthai = 'HOAT_DONG'
JOIN khuvuc kvdoi ON kvdoi.idkhuvuc = db.idkhuvucdaidien
WHERE dk.trangthai = 'HOAT_DONG'
  AND dk.yeu_cau_thanh_tich IN ('VO_DICH','A_QUAN','HANG_BA','TOP_N','THEO_XEP_HANG')
  AND kvdoi.capkhuvuc = dk.capdoituongthamgia
  AND tt.idcapgiaidau = dk.idcapgiaidau_thanh_tich_nguon
  AND (db.idkhuvucdaidien = gdich.idkhuvucphamvi OR fn_khuvuc_la_con(db.idkhuvucdaidien, gdich.idkhuvucphamvi) = 1)
  AND (
      (dk.yeu_cau_thanh_tich = 'VO_DICH' AND tt.hang_dat_duoc = 1)
      OR (dk.yeu_cau_thanh_tich = 'A_QUAN' AND tt.hang_dat_duoc = 2)
      OR (dk.yeu_cau_thanh_tich = 'HANG_BA' AND tt.hang_dat_duoc = 3)
      OR (dk.yeu_cau_thanh_tich IN ('TOP_N','THEO_XEP_HANG') AND tt.hang_dat_duoc <= dk.hang_toi_thieu_duoc_phep)
  );

-- =========================================================
-- 10. Migrate current data safely
-- =========================================================

-- 10.1. Create default non-blocking participation conditions from existing quytacchondoi.
INSERT INTO dieukienthamgiagiai (
    idgiaidau,
    idquytac,
    ten_dieukien,
    capdoituongthamgia,
    yeu_cau_thanh_tich,
    idcapgiaidau_thanh_tich_nguon,
    hang_toi_thieu_duoc_phep,
    so_mua_giai_gan_nhat_duoc_tinh,
    chi_tinh_giai_chinh_thuc,
    bat_buoc_cung_khuvuc,
    cho_phep_btc_duyet_ngoai_le,
    mota,
    trangthai
)
SELECT
    qt.idgiaidau,
    qt.idquytac,
    CONCAT('Dieu kien tham gia mac dinh - ', gd.tengiaidau),
    qt.capdoituongthamgia,
    qt.yeu_cau_thanh_tich,
    qt.idcapgiaidau_thanh_tich_nguon,
    qt.hang_toi_thieu_duoc_phep,
    qt.so_mua_giai_gan_nhat_duoc_tinh,
    1,
    1,
    qt.cho_phep_btc_duyet_ngoai_le,
    'Tao tu quytacchondoi hien co. Logic da chuan hoa bang ma va trigger.',
    'HOAT_DONG'
FROM quytacchondoi qt
JOIN giaidau gd ON gd.idgiaidau = qt.idgiaidau
WHERE NOT EXISTS (
    SELECT 1 FROM dieukienthamgiagiai dk
    WHERE dk.idgiaidau = qt.idgiaidau AND dk.idquytac = qt.idquytac
);

-- 10.2. Convert ranking rows into structured achievements.
INSERT INTO thanhtichdoibong (
    iddoibong,
    idgiaidau,
    idvongdau,
    idbangxephang,
    idchitietbxh,
    idcapgiaidau,
    idkhuvuc,
    mua_giai,
    hang_dat_duoc,
    danhhieu,
    ngay_cong_nhan,
    nguon_ghi_nhan,
    ghi_chu,
    trangthai
)
SELECT
    ct.iddoibong,
    bx.idgiaidau,
    bx.idvongdau,
    bx.idbangxephang,
    ct.idchitietbxh,
    gd.idcapgiaidau,
    gd.idkhuvucphamvi,
    YEAR(gd.thoigianketthuc),
    ct.hang,
    CASE
        WHEN ct.hang = 1 THEN 'VO_DICH'
        WHEN ct.hang = 2 THEN 'A_QUAN'
        WHEN ct.hang = 3 THEN 'HANG_BA'
        WHEN ct.hang <= 4 THEN 'TOP_4'
        WHEN ct.hang <= 8 THEN 'TOP_8'
        ELSE 'THAM_DU'
    END,
    COALESCE(DATE(bx.ngaycongbo), gd.thoigianketthuc),
    'BANG_XEP_HANG',
    'Tu dong tao tu bang xep hang hien co.',
    'HOP_LE'
FROM chitietbangxephang ct
JOIN bangxephang bx ON bx.idbangxephang = ct.idbangxephang
JOIN giaidau gd ON gd.idgiaidau = bx.idgiaidau
ON DUPLICATE KEY UPDATE
    idbangxephang = VALUES(idbangxephang),
    idchitietbxh = VALUES(idchitietbxh),
    hang_dat_duoc = VALUES(hang_dat_duoc),
    danhhieu = VALUES(danhhieu),
    ngay_cong_nhan = VALUES(ngay_cong_nhan),
    ngaycapnhat = NOW();

-- 10.3. Preserve existing approved registrations as qualified records.
INSERT INTO doidudieukienthamgia (
    idgiaidau,
    iddoibong,
    iddieukienthamgia,
    idthanhtich,
    nguon_dieukien,
    lydo_dieukien,
    trangthai,
    ngay_xac_nhan,
    ghichu
)
SELECT
    dkg.idgiaidau,
    dkg.iddoibong,
    (
        SELECT dk.iddieukienthamgia
        FROM dieukienthamgiagiai dk
        WHERE dk.idgiaidau = dkg.idgiaidau
        ORDER BY dk.iddieukienthamgia
        LIMIT 1
    ),
    NULL,
    'DANG_KY_TU_DO',
    'Ho so dang ky da duyet truoc khi bo sung co che xet tu cach.',
    'DA_DUYET',
    NOW(),
    'Migration v2 strict'
FROM dangkygiaidau dkg
WHERE dkg.trangthai = 'DA_DUYET'
ON DUPLICATE KEY UPDATE
    trangthai = IF(doidudieukienthamgia.trangthai IN ('TU_CHOI','HUY_TU_CACH'), doidudieukienthamgia.trangthai, VALUES(trangthai)),
    ghichu = VALUES(ghichu);

-- 10.4. Link old registration rows to generated eligibility rows.
UPDATE dangkygiaidau dkg
JOIN doidudieukienthamgia ddk
  ON ddk.idgiaidau = dkg.idgiaidau
 AND ddk.iddoibong = dkg.iddoibong
SET dkg.iddieukien = ddk.iddieukien,
    dkg.nguon_dang_ky = CASE
        WHEN ddk.nguon_dieukien = 'THANH_TICH' THEN 'HE_THONG_DE_XUAT'
        WHEN ddk.nguon_dieukien = 'DANG_KY_TU_DO' THEN 'TU_DANG_KY'
        ELSE dkg.nguon_dang_ky
    END,
    dkg.lydo_xet_tu_cach = COALESCE(dkg.lydo_xet_tu_cach, ddk.lydo_dieukien)
WHERE dkg.iddieukien IS NULL;

-- =========================================================
-- 11. Clean helper procedures
-- =========================================================

DROP PROCEDURE IF EXISTS sp_vtms_add_column_if_not_exists;
DROP PROCEDURE IF EXISTS sp_vtms_add_index_if_not_exists;
DROP PROCEDURE IF EXISTS sp_vtms_add_fk_if_not_exists;

-- =========================================================
-- 12. Quick checks
-- =========================================================

SELECT 'dieukienthamgiagiai' AS bang, COUNT(*) AS so_dong FROM dieukienthamgiagiai
UNION ALL
SELECT 'thanhtichdoibong' AS bang, COUNT(*) AS so_dong FROM thanhtichdoibong
UNION ALL
SELECT 'suatthamdu' AS bang, COUNT(*) AS so_dong FROM suatthamdu
UNION ALL
SELECT 'doidudieukienthamgia' AS bang, COUNT(*) AS so_dong FROM doidudieukienthamgia;

