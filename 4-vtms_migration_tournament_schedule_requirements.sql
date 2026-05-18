-- VTMS migration 4
-- Purpose:
-- - Preserve tournament creation choices for later schedule/match generation.
-- - Support multiple allowed achievements per tournament eligibility rule.
-- - Add round/group scheduling fields.
-- - Add match generation session metadata and knockout slot helpers.
-- This migration is additive and idempotent. Run after files 0, 1, 2, 3.

USE vtms;

SET FOREIGN_KEY_CHECKS = 0;

DROP PROCEDURE IF EXISTS sp_vtms4_add_column_if_not_exists;
DROP PROCEDURE IF EXISTS sp_vtms4_add_index_if_not_exists;
DROP PROCEDURE IF EXISTS sp_vtms4_add_fk_if_not_exists;
DROP PROCEDURE IF EXISTS sp_vtms4_drop_check_if_exists;
DROP PROCEDURE IF EXISTS sp_vtms4_add_check_if_not_exists;

DELIMITER $$

CREATE PROCEDURE sp_vtms4_add_column_if_not_exists(
    IN p_table_name VARCHAR(64),
    IN p_column_name VARCHAR(64),
    IN p_column_definition TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = p_table_name
          AND COLUMN_NAME = p_column_name
    ) THEN
        SET @sql_text = CONCAT('ALTER TABLE `', p_table_name, '` ADD COLUMN ', p_column_definition);
        PREPARE stmt FROM @sql_text;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

CREATE PROCEDURE sp_vtms4_add_index_if_not_exists(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64),
    IN p_index_definition TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = p_table_name
          AND INDEX_NAME = p_index_name
    ) THEN
        SET @sql_text = CONCAT('ALTER TABLE `', p_table_name, '` ADD ', p_index_definition);
        PREPARE stmt FROM @sql_text;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

CREATE PROCEDURE sp_vtms4_add_fk_if_not_exists(
    IN p_table_name VARCHAR(64),
    IN p_fk_name VARCHAR(64),
    IN p_fk_definition TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = p_table_name
          AND CONSTRAINT_NAME = p_fk_name
          AND CONSTRAINT_TYPE = 'FOREIGN KEY'
    ) THEN
        SET @sql_text = CONCAT('ALTER TABLE `', p_table_name, '` ADD CONSTRAINT `', p_fk_name, '` ', p_fk_definition);
        PREPARE stmt FROM @sql_text;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

CREATE PROCEDURE sp_vtms4_drop_check_if_exists(
    IN p_table_name VARCHAR(64),
    IN p_check_name VARCHAR(64)
)
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = p_table_name
          AND CONSTRAINT_NAME = p_check_name
          AND CONSTRAINT_TYPE = 'CHECK'
    ) THEN
        SET @sql_text = CONCAT('ALTER TABLE `', p_table_name, '` DROP CONSTRAINT `', p_check_name, '`');
        PREPARE stmt FROM @sql_text;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

CREATE PROCEDURE sp_vtms4_add_check_if_not_exists(
    IN p_table_name VARCHAR(64),
    IN p_check_name VARCHAR(64),
    IN p_check_definition TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = p_table_name
          AND CONSTRAINT_NAME = p_check_name
          AND CONSTRAINT_TYPE = 'CHECK'
    ) THEN
        SET @sql_text = CONCAT('ALTER TABLE `', p_table_name, '` ADD CONSTRAINT `', p_check_name, '` CHECK (', p_check_definition, ')');
        PREPARE stmt FROM @sql_text;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$

DELIMITER ;

-- 1. Tournament creation metadata.
CALL sp_vtms4_add_column_if_not_exists('giaidau', 'hinhanh_kieu', "`hinhanh_kieu` VARCHAR(20) NULL AFTER `hinhanh`");
CALL sp_vtms4_add_column_if_not_exists('giaidau', 'hinhanh_ten_goc', "`hinhanh_ten_goc` VARCHAR(255) NULL AFTER `hinhanh_kieu`");
CALL sp_vtms4_add_column_if_not_exists('giaidau', 'quymo_tu_dong', "`quymo_tu_dong` TINYINT(1) NOT NULL DEFAULT 1 AFTER `quymo`");
CALL sp_vtms4_add_column_if_not_exists('giaidau', 'quymo_ghi_chu', "`quymo_ghi_chu` VARCHAR(500) NULL AFTER `quymo_tu_dong`");

UPDATE giaidau
SET hinhanh_kieu = CASE
    WHEN hinhanh IS NULL OR TRIM(hinhanh) = '' THEN NULL
    WHEN LOWER(hinhanh) LIKE 'http://%' OR LOWER(hinhanh) LIKE 'https://%' THEN 'URL'
    ELSE 'UPLOAD'
END
WHERE hinhanh_kieu IS NULL;

-- 1b. Tournament regulations: registration fee and volleyball roster limits.
CALL sp_vtms4_add_column_if_not_exists('dieulegiaidau', 'le_phi_tham_gia', "`le_phi_tham_gia` DECIMAL(12,2) NOT NULL DEFAULT 0 AFTER `yeu_cau_duyet_dang_ky`");

CALL sp_vtms4_drop_check_if_exists('dieulegiaidau', 'chk_dieule_vdv');

ALTER TABLE dieulegiaidau
    MODIFY COLUMN so_vdv_toi_thieu_moi_doi INT NOT NULL DEFAULT 6,
    MODIFY COLUMN so_vdv_toi_da_moi_doi INT NOT NULL DEFAULT 14;

CALL sp_vtms4_add_check_if_not_exists(
    'dieulegiaidau',
    'chk_dieule_vdv',
    "`so_vdv_toi_thieu_moi_doi` BETWEEN 6 AND 14 AND `so_vdv_toi_da_moi_doi` BETWEEN 6 AND 14 AND `so_vdv_toi_da_moi_doi` >= `so_vdv_toi_thieu_moi_doi`"
);

CALL sp_vtms4_add_check_if_not_exists(
    'dieulegiaidau',
    'chk_dieule_lephi',
    "`le_phi_tham_gia` >= 0"
);

-- 2. Multiple achievement conditions for one eligibility rule.
CREATE TABLE IF NOT EXISTS dieukienthamgiagiai_thanhtich (
    iddieukien_thanhtich BIGINT AUTO_INCREMENT PRIMARY KEY,
    iddieukienthamgia INT NOT NULL,
    ma_thanhtich VARCHAR(50) NOT NULL,
    hang_tuong_ung INT NULL,
    trangthai VARCHAR(30) NOT NULL DEFAULT 'HOAT_DONG',
    ngaytao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngaycapnhat DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_dktggtt_dieukien
        FOREIGN KEY (iddieukienthamgia)
        REFERENCES dieukienthamgiagiai(iddieukienthamgia)
        ON DELETE CASCADE,
    CONSTRAINT uq_dktggtt_dieukien_thanhtich UNIQUE (iddieukienthamgia, ma_thanhtich),
    CONSTRAINT chk_dktggtt_ma_thanhtich CHECK (
        ma_thanhtich IN ('VO_DICH','A_QUAN','HANG_BA','TOP_4','TOP_8','TOP_N','THAM_DU','KHAC')
    ),
    CONSTRAINT chk_dktggtt_hang CHECK (hang_tuong_ung IS NULL OR hang_tuong_ung >= 1),
    CONSTRAINT chk_dktggtt_trangthai CHECK (trangthai IN ('HOAT_DONG','NGUNG_AP_DUNG'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- The table may already exist from an older migration run. Rebuild this CHECK so
-- the current schema accepts TOP_N, which dieukienthamgiagiai already supports.
CALL sp_vtms4_drop_check_if_exists('dieukienthamgiagiai_thanhtich', 'chk_dktggtt_ma_thanhtich');
CALL sp_vtms4_add_check_if_not_exists(
    'dieukienthamgiagiai_thanhtich',
    'chk_dktggtt_ma_thanhtich',
    "`ma_thanhtich` IN ('VO_DICH','A_QUAN','HANG_BA','TOP_4','TOP_8','TOP_N','THAM_DU','KHAC')"
);

INSERT INTO dieukienthamgiagiai_thanhtich (
    iddieukienthamgia,
    ma_thanhtich,
    hang_tuong_ung,
    trangthai
)
SELECT
    d.iddieukienthamgia,
    CASE
        WHEN d.yeu_cau_thanh_tich = 'VO_DICH' THEN 'VO_DICH'
        WHEN d.yeu_cau_thanh_tich = 'A_QUAN' THEN 'A_QUAN'
        WHEN d.yeu_cau_thanh_tich = 'HANG_BA' THEN 'HANG_BA'
        WHEN d.yeu_cau_thanh_tich = 'TOP_N' THEN 'TOP_N'
        WHEN d.yeu_cau_thanh_tich = 'THEO_XEP_HANG' THEN 'KHAC'
        ELSE 'THAM_DU'
    END AS ma_thanhtich,
    CASE
        WHEN d.yeu_cau_thanh_tich = 'VO_DICH' THEN 1
        WHEN d.yeu_cau_thanh_tich = 'A_QUAN' THEN 2
        WHEN d.yeu_cau_thanh_tich = 'HANG_BA' THEN 3
        WHEN d.yeu_cau_thanh_tich = 'TOP_N' THEN d.hang_toi_thieu_duoc_phep
        WHEN d.hang_toi_thieu_duoc_phep IS NOT NULL THEN d.hang_toi_thieu_duoc_phep
        ELSE NULL
    END AS hang_tuong_ung,
    'HOAT_DONG'
FROM dieukienthamgiagiai d
WHERE NOT EXISTS (
    SELECT 1
    FROM dieukienthamgiagiai_thanhtich x
    WHERE x.iddieukienthamgia = d.iddieukienthamgia
)
ON DUPLICATE KEY UPDATE
    hang_tuong_ung = VALUES(hang_tuong_ung),
    trangthai = VALUES(trangthai);

DELETE t
FROM dieukienthamgiagiai_thanhtich t
JOIN dieukienthamgiagiai d ON d.iddieukienthamgia = t.iddieukienthamgia
WHERE t.ma_thanhtich = 'THAM_DU'
  AND d.yeu_cau_thanh_tich IN ('VO_DICH','A_QUAN','HANG_BA','TOP_N','THEO_XEP_HANG');

INSERT INTO dieukienthamgiagiai_thanhtich (
    iddieukienthamgia,
    ma_thanhtich,
    hang_tuong_ung,
    trangthai
)
SELECT
    d.iddieukienthamgia,
    CASE
        WHEN d.yeu_cau_thanh_tich = 'VO_DICH' THEN 'VO_DICH'
        WHEN d.yeu_cau_thanh_tich = 'A_QUAN' THEN 'A_QUAN'
        WHEN d.yeu_cau_thanh_tich = 'HANG_BA' THEN 'HANG_BA'
        WHEN d.yeu_cau_thanh_tich = 'TOP_N' THEN 'TOP_N'
        ELSE 'KHAC'
    END AS ma_thanhtich,
    CASE
        WHEN d.yeu_cau_thanh_tich = 'VO_DICH' THEN 1
        WHEN d.yeu_cau_thanh_tich = 'A_QUAN' THEN 2
        WHEN d.yeu_cau_thanh_tich = 'HANG_BA' THEN 3
        ELSE d.hang_toi_thieu_duoc_phep
    END AS hang_tuong_ung,
    'HOAT_DONG'
FROM dieukienthamgiagiai d
WHERE d.yeu_cau_thanh_tich IN ('VO_DICH','A_QUAN','HANG_BA','TOP_N','THEO_XEP_HANG')
ON DUPLICATE KEY UPDATE
    hang_tuong_ung = VALUES(hang_tuong_ung),
    trangthai = VALUES(trangthai);

CALL sp_vtms4_add_index_if_not_exists(
    'dieukienthamgiagiai_thanhtich',
    'idx_dktggtt_dieukien',
    'INDEX `idx_dktggtt_dieukien` (`iddieukienthamgia`, `trangthai`)'
);

-- If a tournament still has pending registrations, the registration list is not
-- actually closed/locked yet. Keep data states consistent with the workflow.
UPDATE giaidau g
JOIN (
    SELECT
        idgiaidau,
        SUM(CASE WHEN trangthai = 'CHO_DUYET' THEN 1 ELSE 0 END) AS so_cho_duyet
    FROM dangkygiaidau
    GROUP BY idgiaidau
) x ON x.idgiaidau = g.idgiaidau
SET
    g.trangthaidangky = 'DANG_MO',
    g.trangthaithietlap = CASE
        WHEN g.trangthaithietlap IN ('DA_KHOA_DOI','DA_TAO_CAU_TRUC') THEN 'DANG_THIET_LAP'
        ELSE g.trangthaithietlap
    END
WHERE x.so_cho_duyet > 0
  AND g.trangthaidangky = 'DA_DONG';

-- 3. Round scheduling and grouping configuration.
CALL sp_vtms4_add_column_if_not_exists('vongdau', 'thoigianbatdau', "`thoigianbatdau` DATE NULL AFTER `thutu`");
CALL sp_vtms4_add_column_if_not_exists('vongdau', 'thoigianketthuc', "`thoigianketthuc` DATE NULL AFTER `thoigianbatdau`");
CALL sp_vtms4_add_column_if_not_exists('vongdau', 'so_doi_moi_bang_du_kien', "`so_doi_moi_bang_du_kien` INT NULL AFTER `so_bang_dau`");
CALL sp_vtms4_add_column_if_not_exists('vongdau', 'cach_phan_bo_bang', "`cach_phan_bo_bang` VARCHAR(50) NOT NULL DEFAULT 'MANUAL' AFTER `cach_xep_cap_dau`");
CALL sp_vtms4_add_column_if_not_exists('vongdau', 'cho_phep_bang_le', "`cho_phep_bang_le` TINYINT(1) NOT NULL DEFAULT 0 AFTER `cach_phan_bo_bang`");
CALL sp_vtms4_add_column_if_not_exists('vongdau', 'chenh_lech_toi_da', "`chenh_lech_toi_da` INT NOT NULL DEFAULT 1 AFTER `cho_phep_bang_le`");
CALL sp_vtms4_add_column_if_not_exists('vongdau', 'tieu_chi_so_sanh_bang_le', "`tieu_chi_so_sanh_bang_le` VARCHAR(50) NOT NULL DEFAULT 'DIEM_TRUNG_BINH' AFTER `chenh_lech_toi_da`");
CALL sp_vtms4_add_column_if_not_exists('vongdau', 'ngaycapnhat', "`ngaycapnhat` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP AFTER `ngaytao`");

UPDATE vongdau v
JOIN giaidau g ON g.idgiaidau = v.idgiaidau
SET
    v.thoigianbatdau = COALESCE(v.thoigianbatdau, g.thoigianbatdau),
    v.thoigianketthuc = COALESCE(v.thoigianketthuc, g.thoigianketthuc)
WHERE v.thoigianbatdau IS NULL
   OR v.thoigianketthuc IS NULL;

CALL sp_vtms4_add_index_if_not_exists(
    'vongdau',
    'idx_vongdau_giai_thutu_trangthai',
    'INDEX `idx_vongdau_giai_thutu_trangthai` (`idgiaidau`, `thutu`, `trangthai`)'
);

CALL sp_vtms4_drop_check_if_exists('vongdau', 'chk_vongdau_trangthai');
CALL sp_vtms4_add_check_if_not_exists(
    'vongdau',
    'chk_vongdau_trangthai',
    "`trangthai` IN ('NHAP','DA_TAO_DOI','CHO_PHAN_CONG_BANG','DA_TAO_BANG','DA_TAO_TRAN','DA_CONG_BO_LICH','DANG_DIEN_RA','DA_HOAN_THANH','DA_KET_THUC','DA_HUY')"
);

CALL sp_vtms4_add_check_if_not_exists(
    'vongdau',
    'chk_vongdau_ngay',
    "`thoigianbatdau` IS NULL OR `thoigianketthuc` IS NULL OR `thoigianketthuc` >= `thoigianbatdau`"
);

CALL sp_vtms4_add_check_if_not_exists(
    'vongdau',
    'chk_vongdau_bang_le',
    "`chenh_lech_toi_da` >= 0 AND `tieu_chi_so_sanh_bang_le` IN ('TONG_DIEM','DIEM_TRUNG_BINH','TY_LE_SET','TY_LE_DIEM')"
);

CALL sp_vtms4_add_check_if_not_exists(
    'vongdau',
    'chk_vongdau_phan_bo_bang',
    "`cach_phan_bo_bang` IN ('RANDOM','SEEDED','POT_DRAW','MANUAL','HYBRID')"
);

-- 4. Group scheduling and manual team assignment support.
CALL sp_vtms4_add_column_if_not_exists('bangdau', 'thoigianbatdau', "`thoigianbatdau` DATE NULL AFTER `mota`");
CALL sp_vtms4_add_column_if_not_exists('bangdau', 'thoigianketthuc', "`thoigianketthuc` DATE NULL AFTER `thoigianbatdau`");
CALL sp_vtms4_add_column_if_not_exists('bangdau', 'so_doi_toi_da', "`so_doi_toi_da` INT NULL AFTER `thoigianketthuc`");
CALL sp_vtms4_add_column_if_not_exists('bangdau', 'thutu', "`thutu` INT NULL AFTER `so_doi_toi_da`");
CALL sp_vtms4_add_column_if_not_exists('bangdau', 'ngaycapnhat', "`ngaycapnhat` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP AFTER `ngaytao`");

UPDATE bangdau b
JOIN giaidau g ON g.idgiaidau = b.idgiaidau
SET
    b.thoigianbatdau = COALESCE(b.thoigianbatdau, g.thoigianbatdau),
    b.thoigianketthuc = COALESCE(b.thoigianketthuc, g.thoigianketthuc)
WHERE b.thoigianbatdau IS NULL
   OR b.thoigianketthuc IS NULL;

CALL sp_vtms4_add_index_if_not_exists(
    'bangdau',
    'idx_bangdau_vong_trangthai',
    'INDEX `idx_bangdau_vong_trangthai` (`idvongdau`, `trangthai`, `thutu`)'
);

CALL sp_vtms4_drop_check_if_exists('bangdau', 'chk_bangdau_trangthai');

ALTER TABLE bangdau
    MODIFY COLUMN trangthai VARCHAR(50) NOT NULL DEFAULT 'CHO_PHAN_CONG';

CALL sp_vtms4_add_check_if_not_exists(
    'bangdau',
    'chk_bangdau_trangthai',
    "`trangthai` IN ('CHO_PHAN_CONG','HOAT_DONG','DA_KHOA','DA_XOA')"
);

CALL sp_vtms4_add_check_if_not_exists(
    'bangdau',
    'chk_bangdau_ngay',
    "`thoigianbatdau` IS NULL OR `thoigianketthuc` IS NULL OR `thoigianketthuc` >= `thoigianbatdau`"
);

CALL sp_vtms4_add_column_if_not_exists('doitrongbang', 'seed_no', "`seed_no` INT NULL AFTER `iddoibong`");
CALL sp_vtms4_add_column_if_not_exists('doitrongbang', 'trangthai', "`trangthai` VARCHAR(30) NOT NULL DEFAULT 'HOAT_DONG' AFTER `seed_no`");
CALL sp_vtms4_add_column_if_not_exists('doitrongbang', 'ngaycapnhat', "`ngaycapnhat` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP AFTER `ngaythem`");

CALL sp_vtms4_add_index_if_not_exists(
    'doitrongbang',
    'idx_doitrongbang_bang_trangthai',
    'INDEX `idx_doitrongbang_bang_trangthai` (`idbangdau`, `trangthai`)'
);

CALL sp_vtms4_add_index_if_not_exists(
    'doitrongbang',
    'uq_doitrongbang_seed',
    'UNIQUE INDEX `uq_doitrongbang_seed` (`idbangdau`, `seed_no`)'
);

CALL sp_vtms4_add_check_if_not_exists(
    'doitrongbang',
    'chk_doitrongbang_trangthai',
    "`trangthai` IN ('HOAT_DONG','TAM_LOAI','DA_XOA')"
);

-- 5. Match generation session metadata.
CALL sp_vtms4_add_column_if_not_exists('phiensinhtran', 'idbangdau', "`idbangdau` INT NULL AFTER `idvongdau`");
CALL sp_vtms4_add_column_if_not_exists('phiensinhtran', 'pham_vi_sinh', "`pham_vi_sinh` VARCHAR(50) NOT NULL DEFAULT 'VONG_DAU' AFTER `kieu_sinh`");
CALL sp_vtms4_add_column_if_not_exists('phiensinhtran', 'tong_tran_du_kien', "`tong_tran_du_kien` INT NULL AFTER `cach_xep_cap_dau`");
CALL sp_vtms4_add_column_if_not_exists('phiensinhtran', 'tong_tran_tao', "`tong_tran_tao` INT NOT NULL DEFAULT 0 AFTER `tong_tran_du_kien`");
CALL sp_vtms4_add_column_if_not_exists('phiensinhtran', 'preview_json', "`preview_json` LONGTEXT NULL AFTER `tong_tran_tao`");
CALL sp_vtms4_add_column_if_not_exists('phiensinhtran', 'loi_sinh', "`loi_sinh` VARCHAR(1000) NULL AFTER `preview_json`");
CALL sp_vtms4_add_column_if_not_exists('phiensinhtran', 'checksum_cau_hinh', "`checksum_cau_hinh` VARCHAR(128) NULL AFTER `loi_sinh`");

CALL sp_vtms4_add_index_if_not_exists(
    'phiensinhtran',
    'idx_phiensinhtran_bang',
    'INDEX `idx_phiensinhtran_bang` (`idbangdau`)'
);

CALL sp_vtms4_add_fk_if_not_exists(
    'phiensinhtran',
    'fk_phiensinhtran_bangdau',
    'FOREIGN KEY (`idbangdau`) REFERENCES `bangdau`(`idbangdau`) ON DELETE SET NULL'
);

CALL sp_vtms4_drop_check_if_exists('phiensinhtran', 'chk_pst_trangthai');
CALL sp_vtms4_drop_check_if_exists('phiensinhtran', 'chk_phiensinhtran_trangthai');
CALL sp_vtms4_add_check_if_not_exists(
    'phiensinhtran',
    'chk_phiensinhtran_trangthai',
    "`trangthai` IN ('BAN_NHAP','NHAP','CHO_XAC_NHAN','DANG_SINH','DA_XAC_NHAN','DA_TAO','THAT_BAI','DA_HUY')"
);

CALL sp_vtms4_add_check_if_not_exists(
    'phiensinhtran',
    'chk_phiensinhtran_phamvi',
    "`pham_vi_sinh` IN ('GIAI_DAU','VONG_DAU','BANG_DAU')"
);

-- 6. Match fields for automatic/manual creation and knockout progression.
CALL sp_vtms4_add_column_if_not_exists('trandau', 'idphien', "`idphien` INT NULL AFTER `idbangdau`");
CALL sp_vtms4_add_column_if_not_exists('trandau', 'idvitrithidau', "`idvitrithidau` INT NULL AFTER `iddoibong2`");
CALL sp_vtms4_add_column_if_not_exists('trandau', 'loaitrandau', "`loaitrandau` VARCHAR(50) NOT NULL DEFAULT 'VONG_DIEM' AFTER `ten_tran`");
CALL sp_vtms4_add_column_if_not_exists('trandau', 'vong_so', "`vong_so` INT NULL AFTER `thutu_tran`");
CALL sp_vtms4_add_column_if_not_exists('trandau', 'luot_dau', "`luot_dau` INT NOT NULL DEFAULT 1 AFTER `vong_so`");
CALL sp_vtms4_add_column_if_not_exists('trandau', 'idtrandau_thang_tiep', "`idtrandau_thang_tiep` INT NULL AFTER `luot_dau`");
CALL sp_vtms4_add_column_if_not_exists('trandau', 'slot_thang_tiep', "`slot_thang_tiep` INT NULL AFTER `idtrandau_thang_tiep`");
CALL sp_vtms4_add_column_if_not_exists('trandau', 'idtrandau_thua_tiep', "`idtrandau_thua_tiep` INT NULL AFTER `slot_thang_tiep`");
CALL sp_vtms4_add_column_if_not_exists('trandau', 'slot_thua_tiep', "`slot_thua_tiep` INT NULL AFTER `idtrandau_thua_tiep`");
CALL sp_vtms4_add_column_if_not_exists('trandau', 'ngaycapnhat', "`ngaycapnhat` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP AFTER `ngaytao`");

UPDATE trandau t
JOIN sandau s ON s.idsandau = t.idsandau
SET t.idvitrithidau = s.idvitrithidau
WHERE t.idvitrithidau IS NULL
  AND t.idsandau IS NOT NULL;

UPDATE trandau t
JOIN vongdau v ON v.idvongdau = t.idvongdau
SET t.loaitrandau = CASE
    WHEN v.loaivongdau IN ('VONG_LOAI','CHUNG_KET','TRANH_HANG_BA') THEN 'LOAI_TRUC_TIEP'
    ELSE 'VONG_DIEM'
END
WHERE t.loaitrandau IS NULL
   OR t.loaitrandau = ''
   OR t.loaitrandau = 'VONG_DIEM';

CALL sp_vtms4_add_index_if_not_exists(
    'trandau',
    'idx_trandau_phien',
    'INDEX `idx_trandau_phien` (`idphien`)'
);

CALL sp_vtms4_add_index_if_not_exists(
    'trandau',
    'idx_trandau_vitri',
    'INDEX `idx_trandau_vitri` (`idvitrithidau`)'
);

CALL sp_vtms4_add_index_if_not_exists(
    'trandau',
    'idx_trandau_bang_trangthai',
    'INDEX `idx_trandau_bang_trangthai` (`idbangdau`, `trangthai`, `thoigianbatdau`)'
);

CALL sp_vtms4_add_index_if_not_exists(
    'trandau',
    'idx_trandau_vong_loai',
    'INDEX `idx_trandau_vong_loai` (`idvongdau`, `loaitrandau`, `vong_so`, `thutu_tran`)'
);

CALL sp_vtms4_add_index_if_not_exists(
    'trandau',
    'idx_trandau_tiep_thang',
    'INDEX `idx_trandau_tiep_thang` (`idtrandau_thang_tiep`)'
);

CALL sp_vtms4_add_index_if_not_exists(
    'trandau',
    'idx_trandau_tiep_thua',
    'INDEX `idx_trandau_tiep_thua` (`idtrandau_thua_tiep`)'
);

CALL sp_vtms4_add_fk_if_not_exists(
    'trandau',
    'fk_trandau_phiensinhtran',
    'FOREIGN KEY (`idphien`) REFERENCES `phiensinhtran`(`idphien`) ON DELETE SET NULL'
);

CALL sp_vtms4_add_fk_if_not_exists(
    'trandau',
    'fk_trandau_vitrithidau',
    'FOREIGN KEY (`idvitrithidau`) REFERENCES `vitrithidau`(`idvitrithidau`) ON DELETE SET NULL'
);

CALL sp_vtms4_add_fk_if_not_exists(
    'trandau',
    'fk_trandau_thang_tiep',
    'FOREIGN KEY (`idtrandau_thang_tiep`) REFERENCES `trandau`(`idtrandau`) ON DELETE SET NULL'
);

CALL sp_vtms4_add_fk_if_not_exists(
    'trandau',
    'fk_trandau_thua_tiep',
    'FOREIGN KEY (`idtrandau_thua_tiep`) REFERENCES `trandau`(`idtrandau`) ON DELETE SET NULL'
);

CALL sp_vtms4_drop_check_if_exists('trandau', 'chk_trandau_trangthai');
CALL sp_vtms4_add_check_if_not_exists(
    'trandau',
    'chk_trandau_trangthai',
    "`trangthai` IN ('CHUA_XAC_DINH_DOI','CHO_DOI_DOI','CHO_XEP_LICH','DA_SAN_SANG','DA_XEP_LICH','SAP_DIEN_RA','DANG_DIEN_RA','TAM_DUNG','DA_KET_THUC','DA_HUY')"
);

CALL sp_vtms4_add_check_if_not_exists(
    'trandau',
    'chk_trandau_loaitrandau',
    "`loaitrandau` IN ('VONG_DIEM','LOAI_TRUC_TIEP','GIAO_HUU','TRANH_HANG_BA','CHUNG_KET')"
);

CALL sp_vtms4_add_check_if_not_exists(
    'trandau',
    'chk_trandau_luot_vong',
    "`luot_dau` >= 1 AND (`vong_so` IS NULL OR `vong_so` >= 1)"
);

CALL sp_vtms4_add_check_if_not_exists(
    'trandau',
    'chk_trandau_slot_tiep',
    "(`slot_thang_tiep` IS NULL OR `slot_thang_tiep` IN (1,2)) AND (`slot_thua_tiep` IS NULL OR `slot_thua_tiep` IN (1,2))"
);

-- Backfill generation sessions for legacy matches and link trandau.idphien.
-- Existing seed data had phiensinhtran rows but the matches were not linked.
INSERT INTO phiensinhtran (
    idgiaidau,
    idvongdau,
    idbangdau,
    kieu_sinh,
    pham_vi_sinh,
    cach_xep_cap_dau,
    tong_tran_du_kien,
    tong_tran_tao,
    ghichu,
    trangthai,
    ngayxacnhan
)
SELECT
    t.idgiaidau,
    t.idvongdau,
    t.idbangdau,
    CASE
        WHEN t.loaitrandau IN ('LOAI_TRUC_TIEP','CHUNG_KET','TRANH_HANG_BA') THEN 'VONG_LOAI'
        ELSE 'VONG_DIEM'
    END AS kieu_sinh,
    CASE WHEN t.idbangdau IS NULL THEN 'VONG_DAU' ELSE 'BANG_DAU' END AS pham_vi_sinh,
    CASE
        WHEN t.loaitrandau = 'VONG_DIEM' THEN 'KHONG_AP_DUNG'
        ELSE COALESCE(NULLIF(v.cach_xep_cap_dau, ''), 'KHONG_AP_DUNG')
    END AS cach_xep_cap_dau,
    COUNT(*) AS tong_tran_du_kien,
    COUNT(*) AS tong_tran_tao,
    'Backfill từ các trận đã tồn tại trước migration 4.',
    'DA_TAO',
    NOW()
FROM trandau t
JOIN vongdau v ON v.idvongdau = t.idvongdau
LEFT JOIN phiensinhtran p
    ON p.idgiaidau = t.idgiaidau
   AND p.idvongdau = t.idvongdau
   AND (p.idbangdau <=> t.idbangdau)
   AND p.kieu_sinh = CASE
        WHEN t.loaitrandau IN ('LOAI_TRUC_TIEP','CHUNG_KET','TRANH_HANG_BA') THEN 'VONG_LOAI'
        ELSE 'VONG_DIEM'
   END
WHERE t.idphien IS NULL
  AND p.idphien IS NULL
GROUP BY
    t.idgiaidau,
    t.idvongdau,
    t.idbangdau,
    CASE
        WHEN t.loaitrandau IN ('LOAI_TRUC_TIEP','CHUNG_KET','TRANH_HANG_BA') THEN 'VONG_LOAI'
        ELSE 'VONG_DIEM'
    END,
    CASE WHEN t.idbangdau IS NULL THEN 'VONG_DAU' ELSE 'BANG_DAU' END,
    CASE
        WHEN t.loaitrandau = 'VONG_DIEM' THEN 'KHONG_AP_DUNG'
        ELSE COALESCE(NULLIF(v.cach_xep_cap_dau, ''), 'KHONG_AP_DUNG')
    END;

UPDATE trandau t
JOIN (
    SELECT
        MIN(idphien) AS idphien,
        idgiaidau,
        idvongdau,
        idbangdau,
        kieu_sinh
    FROM phiensinhtran
    GROUP BY idgiaidau, idvongdau, idbangdau, kieu_sinh
) p
    ON p.idgiaidau = t.idgiaidau
   AND p.idvongdau = t.idvongdau
   AND (p.idbangdau <=> t.idbangdau)
   AND p.kieu_sinh = CASE
        WHEN t.loaitrandau IN ('LOAI_TRUC_TIEP','CHUNG_KET','TRANH_HANG_BA') THEN 'VONG_LOAI'
        ELSE 'VONG_DIEM'
   END
SET t.idphien = p.idphien
WHERE t.idphien IS NULL;

UPDATE phiensinhtran p
JOIN (
    SELECT idphien, COUNT(*) AS so_tran
    FROM trandau
    WHERE idphien IS NOT NULL
    GROUP BY idphien
) x ON x.idphien = p.idphien
SET
    p.tong_tran_tao = x.so_tran,
    p.tong_tran_du_kien = COALESCE(p.tong_tran_du_kien, x.so_tran),
    p.trangthai = CASE
        WHEN p.trangthai IN ('BAN_NHAP','NHAP','CHO_XAC_NHAN','DA_XAC_NHAN') THEN 'DA_TAO'
        ELSE p.trangthai
    END;

-- 7. Slot resolution helpers.
CALL sp_vtms4_add_column_if_not_exists('trandauslot', 'slot_label', "`slot_label` VARCHAR(100) NULL AFTER `slot_so`");
CALL sp_vtms4_add_column_if_not_exists('trandauslot', 'resolved_at', "`resolved_at` DATETIME NULL AFTER `source_result`");
CALL sp_vtms4_add_column_if_not_exists('trandauslot', 'ngaycapnhat', "`ngaycapnhat` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP AFTER `resolved_at`");

UPDATE trandauslot
SET slot_label = CONCAT('Slot ', slot_so)
WHERE slot_label IS NULL;

CALL sp_vtms4_add_index_if_not_exists(
    'trandauslot',
    'idx_trandauslot_source',
    'INDEX `idx_trandauslot_source` (`source_type`, `source_match_id`, `source_result`)'
);

-- 8. Convenience view for backend/frontend mapping.
CREATE OR REPLACE VIEW v_dieukien_giai_thanhtich AS
SELECT
    d.iddieukienthamgia,
    d.idgiaidau,
    GROUP_CONCAT(t.ma_thanhtich ORDER BY t.hang_tuong_ung, t.ma_thanhtich SEPARATOR ',') AS thanh_tich_duoc_phep,
    MIN(t.hang_tuong_ung) AS hang_tot_nhat,
    MAX(t.hang_tuong_ung) AS hang_toi_da_duoc_phep
FROM dieukienthamgiagiai d
LEFT JOIN dieukienthamgiagiai_thanhtich t
    ON t.iddieukienthamgia = d.iddieukienthamgia
   AND t.trangthai = 'HOAT_DONG'
GROUP BY d.iddieukienthamgia, d.idgiaidau;

-- 9. Normalize match insert trigger.
-- A round may have groups, but manually created matches are allowed to stay outside any group.
-- If a group is selected, it still must belong to the same round.
DROP TRIGGER IF EXISTS trg_trandau_bi;

DELIMITER $$
CREATE TRIGGER trg_trandau_bi
BEFORE INSERT ON trandau
FOR EACH ROW
BEGIN
    DECLARE v_giaidau INT;
    DECLARE v_cobang TINYINT DEFAULT 0;
    DECLARE v_bang_vong INT;
    DECLARE v_count INT DEFAULT 0;

    SELECT idgiaidau, COALESCE(co_bangdau, 0)
      INTO v_giaidau, v_cobang
      FROM vongdau
     WHERE idvongdau = NEW.idvongdau;

    IF v_giaidau <> NEW.idgiaidau THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Trận đấu phải thuộc đúng giải của vòng đấu.';
    END IF;

    IF v_cobang = 0 AND NEW.idbangdau IS NOT NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vòng không có bảng đấu thì trận đấu không được gắn bảng đấu.';
    END IF;

    IF NEW.idbangdau IS NOT NULL THEN
        SELECT idvongdau
          INTO v_bang_vong
          FROM bangdau
         WHERE idbangdau = NEW.idbangdau;

        IF v_bang_vong <> NEW.idvongdau THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bảng đấu của trận phải thuộc đúng vòng đấu.';
        END IF;
    END IF;

    IF NEW.iddoibong1 IS NOT NULL THEN
        SELECT COUNT(*)
          INTO v_count
          FROM doitrongvongdau
         WHERE idvongdau = NEW.idvongdau
           AND iddoibong = NEW.iddoibong1;

        IF v_count = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đội 1 không thuộc vòng đấu.';
        END IF;
    END IF;

    IF NEW.iddoibong2 IS NOT NULL THEN
        SELECT COUNT(*)
          INTO v_count
          FROM doitrongvongdau
         WHERE idvongdau = NEW.idvongdau
           AND iddoibong = NEW.iddoibong2;

        IF v_count = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Đội 2 không thuộc vòng đấu.';
        END IF;
    END IF;
END$$
DELIMITER ;

SET FOREIGN_KEY_CHECKS = 1;

DROP PROCEDURE IF EXISTS sp_vtms4_add_column_if_not_exists;
DROP PROCEDURE IF EXISTS sp_vtms4_add_index_if_not_exists;
DROP PROCEDURE IF EXISTS sp_vtms4_add_fk_if_not_exists;
DROP PROCEDURE IF EXISTS sp_vtms4_drop_check_if_exists;
DROP PROCEDURE IF EXISTS sp_vtms4_add_check_if_not_exists;
