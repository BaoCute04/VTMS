-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: localhost    Database: vtms
-- ------------------------------------------------------
-- Server version	5.5.5-10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `bangdau`
--

DROP TABLE IF EXISTS `bangdau`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bangdau` (
  `idbangdau` int(11) NOT NULL AUTO_INCREMENT,
  `idgiaidau` int(11) NOT NULL,
  `idvongdau` int(11) NOT NULL,
  `tenbang` varchar(100) NOT NULL,
  `mota` varchar(500) DEFAULT NULL,
  `thoigianbatdau` date DEFAULT NULL,
  `thoigianketthuc` date DEFAULT NULL,
  `so_doi_toi_da` int(11) DEFAULT NULL,
  `thutu` int(11) DEFAULT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'CHO_PHAN_CONG',
  `ngaytao` datetime NOT NULL DEFAULT current_timestamp(),
  `ngaycapnhat` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`idbangdau`),
  UNIQUE KEY `uq_bangdau_ten` (`idvongdau`,`tenbang`),
  KEY `fk_bangdau_giaidau` (`idgiaidau`),
  KEY `idx_bangdau_vong_trangthai` (`idvongdau`,`trangthai`,`thutu`),
  CONSTRAINT `fk_bangdau_giaidau` FOREIGN KEY (`idgiaidau`) REFERENCES `giaidau` (`idgiaidau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_bangdau_vong` FOREIGN KEY (`idvongdau`) REFERENCES `vongdau` (`idvongdau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_bangdau_trangthai` CHECK (`trangthai` in ('CHO_PHAN_CONG','HOAT_DONG','DA_KHOA','DA_XOA')),
  CONSTRAINT `chk_bangdau_ngay` CHECK (`thoigianbatdau` is null or `thoigianketthuc` is null or `thoigianketthuc` >= `thoigianbatdau`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bangdau`
--

LOCK TABLES `bangdau` WRITE;
/*!40000 ALTER TABLE `bangdau` DISABLE KEYS */;
/*!40000 ALTER TABLE `bangdau` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_bangdau_bi
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `bangxephang`
--

DROP TABLE IF EXISTS `bangxephang`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bangxephang` (
  `idbangxephang` int(11) NOT NULL AUTO_INCREMENT,
  `idgiaidau` int(11) NOT NULL,
  `idvongdau` int(11) DEFAULT NULL,
  `idbangdau` int(11) DEFAULT NULL,
  `tenbangxephang` varchar(300) NOT NULL,
  `phamvi` varchar(50) NOT NULL DEFAULT 'TOAN_GIAI',
  `trangthai` varchar(50) NOT NULL DEFAULT 'BAN_NHAP',
  `ngaytao` datetime NOT NULL DEFAULT current_timestamp(),
  `ngaycongbo` datetime DEFAULT NULL,
  PRIMARY KEY (`idbangxephang`),
  UNIQUE KEY `uq_bxh_scope` (`idgiaidau`,`idvongdau`,`idbangdau`,`tenbangxephang`),
  KEY `fk_bxh_vong` (`idvongdau`),
  KEY `fk_bxh_bang` (`idbangdau`),
  CONSTRAINT `fk_bxh_bang` FOREIGN KEY (`idbangdau`) REFERENCES `bangdau` (`idbangdau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_bxh_giaidau` FOREIGN KEY (`idgiaidau`) REFERENCES `giaidau` (`idgiaidau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_bxh_vong` FOREIGN KEY (`idvongdau`) REFERENCES `vongdau` (`idvongdau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_bxh_phamvi` CHECK (`phamvi` in ('TOAN_GIAI','THEO_VONG','THEO_BANG')),
  CONSTRAINT `chk_bxh_trangthai` CHECK (`trangthai` in ('BAN_NHAP','DA_CONG_BO','DA_CAP_NHAT')),
  CONSTRAINT `chk_bxh_ngaycongbo` CHECK (`ngaycongbo` is null or `ngaycongbo` >= `ngaytao`)
) ENGINE=InnoDB AUTO_INCREMENT=105 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bangxephang`
--

LOCK TABLES `bangxephang` WRITE;
/*!40000 ALTER TABLE `bangxephang` DISABLE KEYS */;
/*!40000 ALTER TABLE `bangxephang` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bantochuc`
--

DROP TABLE IF EXISTS `bantochuc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bantochuc` (
  `idbantochuc` int(11) NOT NULL AUTO_INCREMENT,
  `idnguoidung` int(11) NOT NULL,
  `idcapbantochuc` int(11) NOT NULL,
  `idkhuvucquanly` int(11) NOT NULL,
  `idbantochuccha` int(11) DEFAULT NULL,
  `donvi` varchar(300) NOT NULL,
  `chucvu` varchar(200) DEFAULT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'CHO_XAC_NHAN',
  PRIMARY KEY (`idbantochuc`),
  UNIQUE KEY `idnguoidung` (`idnguoidung`),
  KEY `fk_btc_capbtc` (`idcapbantochuc`),
  KEY `fk_btc_khuvuc` (`idkhuvucquanly`),
  KEY `fk_btc_cha` (`idbantochuccha`),
  CONSTRAINT `fk_btc_capbtc` FOREIGN KEY (`idcapbantochuc`) REFERENCES `capbantochuc` (`idcapbantochuc`) ON UPDATE CASCADE,
  CONSTRAINT `fk_btc_cha` FOREIGN KEY (`idbantochuccha`) REFERENCES `bantochuc` (`idbantochuc`) ON UPDATE CASCADE,
  CONSTRAINT `fk_btc_khuvuc` FOREIGN KEY (`idkhuvucquanly`) REFERENCES `khuvuc` (`idkhuvuc`) ON UPDATE CASCADE,
  CONSTRAINT `fk_btc_nguoidung` FOREIGN KEY (`idnguoidung`) REFERENCES `nguoidung` (`idnguoidung`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_btc_trangthai` CHECK (`trangthai` in ('HOAT_DONG','CHO_XAC_NHAN','TAM_KHOA','NGUNG_HOAT_DONG'))
) ENGINE=InnoDB AUTO_INCREMENT=104 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bantochuc`
--

LOCK TABLES `bantochuc` WRITE;
/*!40000 ALTER TABLE `bantochuc` DISABLE KEYS */;
INSERT INTO `bantochuc` VALUES (1,2,1,1,NULL,'Liên đoàn Bóng chuyền Việt Nam','BTC cấp quốc gia','HOAT_DONG'),(2,3,2,2,1,'BTC Bóng chuyền TP.HCM','BTC cấp tỉnh/thành','HOAT_DONG'),(3,4,3,10,2,'BTC Bóng chuyền Gò Vấp','BTC cấp quận/huyện','HOAT_DONG'),(4,5,4,30,3,'BTC Bóng chuyền IUH','BTC cấp đơn vị','HOAT_DONG'),(101,101,3,11,2,'BTC Bóng chuyền Quận 1','BTC cấp quận/huyện','HOAT_DONG'),(102,102,3,12,2,'BTC Bóng chuyền Quận 12','BTC cấp quận/huyện','HOAT_DONG'),(103,103,3,13,2,'BTC Bóng chuyền Bình Thạnh','BTC cấp quận/huyện','HOAT_DONG');
/*!40000 ALTER TABLE `bantochuc` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_bantochuc_bi
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `baocaosuco`
--

DROP TABLE IF EXISTS `baocaosuco`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `baocaosuco` (
  `idbaocao` int(11) NOT NULL AUTO_INCREMENT,
  `idtrandau` int(11) NOT NULL,
  `idtrongtai` int(11) NOT NULL,
  `tieude` varchar(300) NOT NULL,
  `noidung` varchar(2000) NOT NULL,
  `minhchung` varchar(500) DEFAULT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'DA_GUI',
  `ngaybaocao` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`idbaocao`),
  KEY `fk_bcsc_tran` (`idtrandau`),
  KEY `fk_bcsc_trongtai` (`idtrongtai`),
  CONSTRAINT `fk_bcsc_tran` FOREIGN KEY (`idtrandau`) REFERENCES `trandau` (`idtrandau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_bcsc_trongtai` FOREIGN KEY (`idtrongtai`) REFERENCES `trongtai` (`idtrongtai`) ON UPDATE CASCADE,
  CONSTRAINT `chk_bcsc_trangthai` CHECK (`trangthai` in ('DA_GUI','DA_TIEP_NHAN','DA_XU_LY','TU_CHOI'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `baocaosuco`
--

LOCK TABLES `baocaosuco` WRITE;
/*!40000 ALTER TABLE `baocaosuco` DISABLE KEYS */;
/*!40000 ALTER TABLE `baocaosuco` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `capbantochuc`
--

DROP TABLE IF EXISTS `capbantochuc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `capbantochuc` (
  `idcapbantochuc` int(11) NOT NULL AUTO_INCREMENT,
  `macapbantochuc` varchar(50) NOT NULL,
  `tencapbantochuc` varchar(200) NOT NULL,
  `capkhuvucquanly` varchar(50) NOT NULL,
  `thutu` int(11) NOT NULL,
  `mota` varchar(1000) DEFAULT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'HOAT_DONG',
  PRIMARY KEY (`idcapbantochuc`),
  UNIQUE KEY `macapbantochuc` (`macapbantochuc`),
  CONSTRAINT `chk_capbtc_ma` CHECK (`macapbantochuc` in ('QUOC_GIA','TINH_THANH','QUAN_HUYEN','DON_VI')),
  CONSTRAINT `chk_capbtc_kv` CHECK (`capkhuvucquanly` in ('QUOC_GIA','TINH_THANH','QUAN_HUYEN','DON_VI')),
  CONSTRAINT `chk_capbtc_thutu` CHECK (`thutu` > 0),
  CONSTRAINT `chk_capbtc_trangthai` CHECK (`trangthai` in ('HOAT_DONG','NGUNG_SU_DUNG'))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `capbantochuc`
--

LOCK TABLES `capbantochuc` WRITE;
/*!40000 ALTER TABLE `capbantochuc` DISABLE KEYS */;
INSERT INTO `capbantochuc` VALUES (1,'QUOC_GIA','Ban tổ chức cấp quốc gia','QUOC_GIA',1,'Cấp cao nhất trong VTMS','HOAT_DONG'),(2,'TINH_THANH','Ban tổ chức cấp tỉnh/thành','TINH_THANH',2,'Quản lý tỉnh/thành','HOAT_DONG'),(3,'QUAN_HUYEN','Ban tổ chức cấp quận/huyện','QUAN_HUYEN',3,'Quản lý quận/huyện','HOAT_DONG'),(4,'DON_VI','Ban tổ chức cấp đơn vị','DON_VI',4,'Quản lý đơn vị/cơ sở','HOAT_DONG');
/*!40000 ALTER TABLE `capbantochuc` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `capgiaidau`
--

DROP TABLE IF EXISTS `capgiaidau`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `capgiaidau` (
  `idcapgiaidau` int(11) NOT NULL AUTO_INCREMENT,
  `macapgiaidau` varchar(50) NOT NULL,
  `tencapgiaidau` varchar(200) NOT NULL,
  `capkhuvucphamvi` varchar(50) NOT NULL,
  `capdoituongthamgia` varchar(50) NOT NULL,
  `apdung_bangdau_macdinh` tinyint(1) NOT NULL DEFAULT 0,
  `mota` varchar(1000) DEFAULT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'HOAT_DONG',
  PRIMARY KEY (`idcapgiaidau`),
  UNIQUE KEY `macapgiaidau` (`macapgiaidau`),
  CONSTRAINT `chk_capgd_ma` CHECK (`macapgiaidau` in ('QUOC_GIA','TINH_THANH','QUAN_HUYEN','DON_VI')),
  CONSTRAINT `chk_capgd_scope` CHECK (`capkhuvucphamvi` in ('QUOC_GIA','TINH_THANH','QUAN_HUYEN','DON_VI')),
  CONSTRAINT `chk_capgd_participant` CHECK (`capdoituongthamgia` in ('TINH_THANH','QUAN_HUYEN','XA_PHUONG','DON_VI')),
  CONSTRAINT `chk_capgd_trangthai` CHECK (`trangthai` in ('HOAT_DONG','NGUNG_SU_DUNG'))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `capgiaidau`
--

LOCK TABLES `capgiaidau` WRITE;
/*!40000 ALTER TABLE `capgiaidau` DISABLE KEYS */;
INSERT INTO `capgiaidau` VALUES (1,'QUOC_GIA','Giải cấp quốc gia','QUOC_GIA','TINH_THANH',0,'Giải giữa các tỉnh/thành, không chia bảng mặc định','HOAT_DONG'),(2,'TINH_THANH','Giải cấp tỉnh/thành','TINH_THANH','QUAN_HUYEN',1,'Giải giữa các quận/huyện','HOAT_DONG'),(3,'QUAN_HUYEN','Giải cấp quận/huyện','QUAN_HUYEN','XA_PHUONG',1,'Giải giữa các xã/phường','HOAT_DONG'),(4,'DON_VI','Giải cấp đơn vị','DON_VI','DON_VI',1,'Giải giữa các đơn vị tự đăng ký','HOAT_DONG');
/*!40000 ALTER TABLE `capgiaidau` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chitietbangxephang`
--

DROP TABLE IF EXISTS `chitietbangxephang`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chitietbangxephang` (
  `idchitietbxh` int(11) NOT NULL AUTO_INCREMENT,
  `idbangxephang` int(11) NOT NULL,
  `iddoibong` int(11) NOT NULL,
  `hang` int(11) NOT NULL,
  `sotran` int(11) NOT NULL DEFAULT 0,
  `thang` int(11) NOT NULL DEFAULT 0,
  `thua` int(11) NOT NULL DEFAULT 0,
  `sosetthang` int(11) NOT NULL DEFAULT 0,
  `sosetthua` int(11) NOT NULL DEFAULT 0,
  `diem` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`idchitietbxh`),
  UNIQUE KEY `uq_ctbxh_doi` (`idbangxephang`,`iddoibong`),
  UNIQUE KEY `uq_ctbxh_hang` (`idbangxephang`,`hang`),
  KEY `fk_ctbxh_doi` (`iddoibong`),
  CONSTRAINT `fk_ctbxh_bxh` FOREIGN KEY (`idbangxephang`) REFERENCES `bangxephang` (`idbangxephang`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_ctbxh_doi` FOREIGN KEY (`iddoibong`) REFERENCES `doibong` (`iddoibong`) ON UPDATE CASCADE,
  CONSTRAINT `chk_ctbxh_hang` CHECK (`hang` > 0),
  CONSTRAINT `chk_ctbxh_nonnegative` CHECK (`sotran` >= 0 and `thang` >= 0 and `thua` >= 0 and `sosetthang` >= 0 and `sosetthua` >= 0 and `diem` >= 0),
  CONSTRAINT `chk_ctbxh_tongtran` CHECK (`sotran` >= `thang` + `thua`)
) ENGINE=InnoDB AUTO_INCREMENT=105 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chitietbangxephang`
--

LOCK TABLES `chitietbangxephang` WRITE;
/*!40000 ALTER TABLE `chitietbangxephang` DISABLE KEYS */;
/*!40000 ALTER TABLE `chitietbangxephang` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chitietdoihinh`
--

DROP TABLE IF EXISTS `chitietdoihinh`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chitietdoihinh` (
  `idchitietdoihinh` int(11) NOT NULL AUTO_INCREMENT,
  `iddoihinh` int(11) NOT NULL,
  `idvandongvien` int(11) NOT NULL,
  `vitri` varchar(100) NOT NULL,
  `sothutu` int(11) DEFAULT NULL,
  `ghichu` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`idchitietdoihinh`),
  UNIQUE KEY `uq_ctdh_vdv` (`iddoihinh`,`idvandongvien`),
  UNIQUE KEY `uq_ctdh_sothutu` (`iddoihinh`,`sothutu`),
  KEY `fk_ctdh_vdv` (`idvandongvien`),
  CONSTRAINT `fk_ctdh_doihinh` FOREIGN KEY (`iddoihinh`) REFERENCES `doihinh` (`iddoihinh`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_ctdh_vdv` FOREIGN KEY (`idvandongvien`) REFERENCES `vandongvien` (`idvandongvien`) ON UPDATE CASCADE,
  CONSTRAINT `chk_ctdh_vitri` CHECK (`vitri` in ('CHU_CONG','PHU_CONG','CHUYEN_HAI','DOI_CHUYEN','LIBERO','DOI_TRU')),
  CONSTRAINT `chk_ctdh_sothutu` CHECK (`sothutu` is null or `sothutu` > 0)
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chitietdoihinh`
--

LOCK TABLES `chitietdoihinh` WRITE;
/*!40000 ALTER TABLE `chitietdoihinh` DISABLE KEYS */;
INSERT INTO `chitietdoihinh` VALUES (46,3,11,'CHU_CONG',1,NULL),(47,3,12,'PHU_CONG',2,NULL),(48,3,13,'CHUYEN_HAI',3,NULL),(49,3,14,'DOI_CHUYEN',4,NULL),(50,3,15,'LIBERO',5,NULL),(51,3,16,'DOI_TRU',6,NULL),(52,4,17,'CHU_CONG',1,NULL),(53,4,18,'PHU_CONG',2,NULL),(54,4,19,'CHUYEN_HAI',3,NULL),(55,4,20,'DOI_CHUYEN',4,NULL),(56,4,21,'LIBERO',5,NULL),(57,4,22,'DOI_TRU',6,NULL);
/*!40000 ALTER TABLE `chitietdoihinh` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dangkygiaidau`
--

DROP TABLE IF EXISTS `dangkygiaidau`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dangkygiaidau` (
  `iddangky` int(11) NOT NULL AUTO_INCREMENT,
  `idgiaidau` int(11) NOT NULL,
  `iddoibong` int(11) NOT NULL,
  `idhuanluyenvien` int(11) NOT NULL,
  `iddoihinh` int(11) DEFAULT NULL,
  `iddieukien` int(11) DEFAULT NULL,
  `nguon_dang_ky` varchar(50) NOT NULL DEFAULT 'TU_DANG_KY',
  `ngaydangky` datetime NOT NULL DEFAULT current_timestamp(),
  `trangthai` varchar(50) NOT NULL DEFAULT 'CHO_DUYET',
  `lydotuchoi` varchar(1000) DEFAULT NULL,
  `lydo_xet_tu_cach` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`iddangky`),
  UNIQUE KEY `uq_dkgd_doi` (`idgiaidau`,`iddoibong`),
  KEY `fk_dkgd_doibong` (`iddoibong`),
  KEY `fk_dkgd_hlv` (`idhuanluyenvien`),
  KEY `idx_dkgd_dieukien_v2` (`iddieukien`),
  KEY `idx_dangkygiaidau_iddoihinh` (`iddoihinh`),
  CONSTRAINT `fk_dangkygiaidau_doihinh` FOREIGN KEY (`iddoihinh`) REFERENCES `doihinh` (`iddoihinh`) ON DELETE SET NULL,
  CONSTRAINT `fk_dkgd_dieukien_v2` FOREIGN KEY (`iddieukien`) REFERENCES `doidudieukienthamgia` (`iddieukien`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_dkgd_doibong` FOREIGN KEY (`iddoibong`) REFERENCES `doibong` (`iddoibong`) ON UPDATE CASCADE,
  CONSTRAINT `fk_dkgd_giaidau` FOREIGN KEY (`idgiaidau`) REFERENCES `giaidau` (`idgiaidau`) ON UPDATE CASCADE,
  CONSTRAINT `fk_dkgd_hlv` FOREIGN KEY (`idhuanluyenvien`) REFERENCES `huanluyenvien` (`idhuanluyenvien`) ON UPDATE CASCADE,
  CONSTRAINT `chk_dkgd_trangthai` CHECK (`trangthai` in ('CHO_DUYET','DA_DUYET','TU_CHOI','DA_HUY')),
  CONSTRAINT `chk_dkgd_lydo` CHECK (`trangthai` <> 'TU_CHOI' or `lydotuchoi` is not null)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dangkygiaidau`
--

LOCK TABLES `dangkygiaidau` WRITE;
/*!40000 ALTER TABLE `dangkygiaidau` DISABLE KEYS */;
INSERT INTO `dangkygiaidau` VALUES (11,106,18,10,3,NULL,'TU_DANG_KY','2026-05-19 21:07:44','DA_DUYET',NULL,NULL),(12,106,19,11,4,NULL,'TU_DANG_KY','2026-05-19 21:08:29','DA_DUYET',NULL,NULL);
/*!40000 ALTER TABLE `dangkygiaidau` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_dangkygiaidau_bi
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_dkgd_dieukien_bi_v2
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_dkgd_dieukien_bu_v2
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `decutucachthamgia`
--

DROP TABLE IF EXISTS `decutucachthamgia`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `decutucachthamgia` (
  `iddecu` int(11) NOT NULL AUTO_INCREMENT,
  `iddoibong` int(11) NOT NULL,
  `idthanhtich` int(11) NOT NULL,
  `idgiaidau_nguon` int(11) NOT NULL,
  `idgiaidau_dich` int(11) NOT NULL,
  `idcapgiaidau_nguon` int(11) NOT NULL,
  `idcapgiaidau_dich` int(11) NOT NULL,
  `idbantochuc_decu` int(11) NOT NULL,
  `idbantochuc_nhan` int(11) NOT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'DU_DIEU_KIEN',
  `lydo_xet` varchar(1000) DEFAULT NULL,
  `ghichu_decu` varchar(1000) DEFAULT NULL,
  `lydo_xacnhan` varchar(1000) DEFAULT NULL,
  `idnguoi_danhdau` int(11) DEFAULT NULL,
  `idnguoi_decu` int(11) DEFAULT NULL,
  `idnguoi_xacnhan` int(11) DEFAULT NULL,
  `ngay_danhdau` datetime DEFAULT NULL,
  `ngay_decu` datetime DEFAULT NULL,
  `ngay_xacnhan` datetime DEFAULT NULL,
  `ngaytao` datetime NOT NULL DEFAULT current_timestamp(),
  `ngaycapnhat` datetime DEFAULT NULL,
  PRIMARY KEY (`iddecu`),
  UNIQUE KEY `uq_decu_thanhtich_giai` (`idthanhtich`,`idgiaidau_dich`),
  KEY `idx_decu_doi` (`iddoibong`),
  KEY `idx_decu_nguon` (`idgiaidau_nguon`),
  KEY `idx_decu_dich` (`idgiaidau_dich`),
  KEY `idx_decu_btc_decu` (`idbantochuc_decu`),
  KEY `idx_decu_btc_nhan` (`idbantochuc_nhan`),
  KEY `idx_decu_trangthai` (`trangthai`),
  CONSTRAINT `fk_decu_cap_dich` FOREIGN KEY (`idcapgiaidau_dich`) REFERENCES `capgiaidau` (`idcapgiaidau`) ON UPDATE CASCADE,
  CONSTRAINT `fk_decu_cap_nguon` FOREIGN KEY (`idcapgiaidau_nguon`) REFERENCES `capgiaidau` (`idcapgiaidau`) ON UPDATE CASCADE,
  CONSTRAINT `fk_decu_doi` FOREIGN KEY (`iddoibong`) REFERENCES `doibong` (`iddoibong`) ON UPDATE CASCADE,
  CONSTRAINT `fk_decu_giai_dich` FOREIGN KEY (`idgiaidau_dich`) REFERENCES `giaidau` (`idgiaidau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_decu_giai_nguon` FOREIGN KEY (`idgiaidau_nguon`) REFERENCES `giaidau` (`idgiaidau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_decu_btc_decu` FOREIGN KEY (`idbantochuc_decu`) REFERENCES `bantochuc` (`idbantochuc`) ON UPDATE CASCADE,
  CONSTRAINT `fk_decu_btc_nhan` FOREIGN KEY (`idbantochuc_nhan`) REFERENCES `bantochuc` (`idbantochuc`) ON UPDATE CASCADE,
  CONSTRAINT `fk_decu_thanhtich` FOREIGN KEY (`idthanhtich`) REFERENCES `thanhtichdoibong` (`idthanhtich`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_decu_tk_danhdau` FOREIGN KEY (`idnguoi_danhdau`) REFERENCES `taikhoan` (`idtaikhoan`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_decu_tk_decu` FOREIGN KEY (`idnguoi_decu`) REFERENCES `taikhoan` (`idtaikhoan`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_decu_tk_xacnhan` FOREIGN KEY (`idnguoi_xacnhan`) REFERENCES `taikhoan` (`idtaikhoan`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_decu_trangthai` CHECK (`trangthai` in ('DU_DIEU_KIEN','DA_DE_CU','DA_XAC_NHAN','TU_CHOI'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `decutucachthamgia`
--

LOCK TABLES `decutucachthamgia` WRITE;
/*!40000 ALTER TABLE `decutucachthamgia` DISABLE KEYS */;
/*!40000 ALTER TABLE `decutucachthamgia` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `diemset`
--

DROP TABLE IF EXISTS `diemset`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `diemset` (
  `iddiemset` int(11) NOT NULL AUTO_INCREMENT,
  `idketqua` int(11) NOT NULL,
  `setthu` int(11) NOT NULL,
  `diemdoi1` int(11) NOT NULL DEFAULT 0,
  `diemdoi2` int(11) NOT NULL DEFAULT 0,
  `doithangset` int(11) NOT NULL,
  PRIMARY KEY (`iddiemset`),
  UNIQUE KEY `uq_diemset` (`idketqua`,`setthu`),
  KEY `fk_diemset_doithang` (`doithangset`),
  CONSTRAINT `fk_diemset_doithang` FOREIGN KEY (`doithangset`) REFERENCES `doibong` (`iddoibong`) ON UPDATE CASCADE,
  CONSTRAINT `fk_diemset_ketqua` FOREIGN KEY (`idketqua`) REFERENCES `ketquatrandau` (`idketqua`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_diemset_setthu` CHECK (`setthu` between 1 and 5),
  CONSTRAINT `chk_diemset_diem` CHECK (`diemdoi1` >= 0 and `diemdoi2` >= 0 and `diemdoi1` <> `diemdoi2`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `diemset`
--

LOCK TABLES `diemset` WRITE;
/*!40000 ALTER TABLE `diemset` DISABLE KEYS */;
/*!40000 ALTER TABLE `diemset` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dieuchinhketqua`
--

DROP TABLE IF EXISTS `dieuchinhketqua`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dieuchinhketqua` (
  `iddieuchinh` int(11) NOT NULL AUTO_INCREMENT,
  `idketqua` int(11) NOT NULL,
  `diemcu` varchar(500) NOT NULL,
  `diemmoi` varchar(500) NOT NULL,
  `lydo` varchar(1000) NOT NULL,
  `minhchung` varchar(500) DEFAULT NULL,
  `idnguoichinhsua` int(11) DEFAULT NULL,
  `ngaychinhsua` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`iddieuchinh`),
  KEY `fk_dckq_ketqua` (`idketqua`),
  KEY `fk_dckq_taikhoan` (`idnguoichinhsua`),
  CONSTRAINT `fk_dckq_ketqua` FOREIGN KEY (`idketqua`) REFERENCES `ketquatrandau` (`idketqua`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_dckq_taikhoan` FOREIGN KEY (`idnguoichinhsua`) REFERENCES `taikhoan` (`idtaikhoan`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dieuchinhketqua`
--

LOCK TABLES `dieuchinhketqua` WRITE;
/*!40000 ALTER TABLE `dieuchinhketqua` DISABLE KEYS */;
/*!40000 ALTER TABLE `dieuchinhketqua` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dieukienthamgiagiai`
--

DROP TABLE IF EXISTS `dieukienthamgiagiai`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dieukienthamgiagiai` (
  `iddieukienthamgia` int(11) NOT NULL AUTO_INCREMENT,
  `idgiaidau` int(11) NOT NULL,
  `idquytac` int(11) DEFAULT NULL,
  `ten_dieukien` varchar(300) NOT NULL,
  `capdoituongthamgia` varchar(50) NOT NULL,
  `yeu_cau_thanh_tich` varchar(50) NOT NULL DEFAULT 'KHONG_YEU_CAU',
  `idcapgiaidau_thanh_tich_nguon` int(11) DEFAULT NULL,
  `hang_toi_thieu_duoc_phep` int(11) DEFAULT NULL,
  `so_mua_giai_gan_nhat_duoc_tinh` int(11) DEFAULT NULL,
  `chi_tinh_giai_chinh_thuc` tinyint(1) NOT NULL DEFAULT 1,
  `bat_buoc_cung_khuvuc` tinyint(1) NOT NULL DEFAULT 1,
  `cho_phep_btc_duyet_ngoai_le` tinyint(1) NOT NULL DEFAULT 1,
  `mota` varchar(1500) DEFAULT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'HOAT_DONG',
  `ngaytao` datetime NOT NULL DEFAULT current_timestamp(),
  `ngaycapnhat` datetime DEFAULT NULL,
  PRIMARY KEY (`iddieukienthamgia`),
  UNIQUE KEY `uq_dktg_giai_ten` (`idgiaidau`,`ten_dieukien`),
  KEY `idx_dktg_giai` (`idgiaidau`),
  KEY `idx_dktg_quytac` (`idquytac`),
  KEY `idx_dktg_capnguon` (`idcapgiaidau_thanh_tich_nguon`),
  KEY `idx_dktg_capdoi` (`capdoituongthamgia`),
  CONSTRAINT `fk_dktg_capnguon` FOREIGN KEY (`idcapgiaidau_thanh_tich_nguon`) REFERENCES `capgiaidau` (`idcapgiaidau`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_dktg_giaidau` FOREIGN KEY (`idgiaidau`) REFERENCES `giaidau` (`idgiaidau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_dktg_quytac` FOREIGN KEY (`idquytac`) REFERENCES `quytacchondoi` (`idquytac`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_dktg_capdoi_v2` CHECK (`capdoituongthamgia` in ('TINH_THANH','QUAN_HUYEN','XA_PHUONG','DON_VI')),
  CONSTRAINT `chk_dktg_yeucau_v2` CHECK (`yeu_cau_thanh_tich` in ('KHONG_YEU_CAU','VO_DICH','A_QUAN','HANG_BA','TOP_N','THEO_XEP_HANG','BTC_CHON','DAC_CACH')),
  CONSTRAINT `chk_dktg_hang_v2` CHECK (`hang_toi_thieu_duoc_phep` is null or `hang_toi_thieu_duoc_phep` >= 1),
  CONSTRAINT `chk_dktg_mua_v2` CHECK (`so_mua_giai_gan_nhat_duoc_tinh` is null or `so_mua_giai_gan_nhat_duoc_tinh` >= 1),
  CONSTRAINT `chk_dktg_bool_v2` CHECK (`chi_tinh_giai_chinh_thuc` in (0,1) and `bat_buoc_cung_khuvuc` in (0,1) and `cho_phep_btc_duyet_ngoai_le` in (0,1)),
  CONSTRAINT `chk_dktg_trangthai_v2` CHECK (`trangthai` in ('HOAT_DONG','TAM_NGUNG','NGUNG_SU_DUNG')),
  CONSTRAINT `chk_dktg_req_logic_v2` CHECK (`yeu_cau_thanh_tich` in ('KHONG_YEU_CAU','BTC_CHON','DAC_CACH') and `idcapgiaidau_thanh_tich_nguon` is null or `yeu_cau_thanh_tich` in ('VO_DICH','A_QUAN','HANG_BA','TOP_N','THEO_XEP_HANG') and `idcapgiaidau_thanh_tich_nguon` is not null),
  CONSTRAINT `chk_dktg_topn_logic_v2` CHECK (`yeu_cau_thanh_tich` <> 'TOP_N' or `yeu_cau_thanh_tich` = 'TOP_N' and `hang_toi_thieu_duoc_phep` is not null and `hang_toi_thieu_duoc_phep` >= 1)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dieukienthamgiagiai`
--

LOCK TABLES `dieukienthamgiagiai` WRITE;
/*!40000 ALTER TABLE `dieukienthamgiagiai` DISABLE KEYS */;
INSERT INTO `dieukienthamgiagiai` VALUES (5,105,105,'Điều kiện tham gia - Vô địch #1 - 6a0b4d309ef9f','QUAN_HUYEN','VO_DICH',3,NULL,1,1,1,1,NULL,'HOAT_DONG','2026-05-19 00:32:32',NULL),(6,105,105,'Điều kiện tham gia - Á quân #2 - 6a0b4d309f3ef','QUAN_HUYEN','A_QUAN',3,NULL,1,1,1,1,NULL,'HOAT_DONG','2026-05-19 00:32:32',NULL),(7,106,106,'Điều kiện tham gia - Vô địch #1 - 6a0c5fab1a794','TINH_THANH','VO_DICH',2,NULL,1,1,1,0,NULL,'NGUNG_SU_DUNG','2026-05-19 20:03:39','2026-05-19 21:34:36'),(8,106,107,'Điều kiện tham gia - Vô địch #1 - 6a0c74fc22721','TINH_THANH','VO_DICH',2,NULL,1,1,1,0,NULL,'HOAT_DONG','2026-05-19 21:34:36',NULL);
/*!40000 ALTER TABLE `dieukienthamgiagiai` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_dieukienthamgiagiai_bi_v2
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_dieukienthamgiagiai_bu_v2
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `dieukienthamgiagiai_thanhtich`
--

DROP TABLE IF EXISTS `dieukienthamgiagiai_thanhtich`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dieukienthamgiagiai_thanhtich` (
  `iddieukien_thanhtich` bigint(20) NOT NULL AUTO_INCREMENT,
  `iddieukienthamgia` int(11) NOT NULL,
  `ma_thanhtich` varchar(50) NOT NULL,
  `hang_tuong_ung` int(11) DEFAULT NULL,
  `trangthai` varchar(30) NOT NULL DEFAULT 'HOAT_DONG',
  `ngaytao` datetime NOT NULL DEFAULT current_timestamp(),
  `ngaycapnhat` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`iddieukien_thanhtich`),
  UNIQUE KEY `uq_dktggtt_dieukien_thanhtich` (`iddieukienthamgia`,`ma_thanhtich`),
  KEY `idx_dktggtt_dieukien` (`iddieukienthamgia`,`trangthai`),
  CONSTRAINT `fk_dktggtt_dieukien` FOREIGN KEY (`iddieukienthamgia`) REFERENCES `dieukienthamgiagiai` (`iddieukienthamgia`) ON DELETE CASCADE,
  CONSTRAINT `chk_dktggtt_hang` CHECK (`hang_tuong_ung` is null or `hang_tuong_ung` >= 1),
  CONSTRAINT `chk_dktggtt_trangthai` CHECK (`trangthai` in ('HOAT_DONG','NGUNG_AP_DUNG')),
  CONSTRAINT `chk_dktggtt_ma_thanhtich` CHECK (`ma_thanhtich` in ('VO_DICH','A_QUAN','HANG_BA','TOP_4','TOP_8','TOP_N','THAM_DU','KHAC'))
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dieukienthamgiagiai_thanhtich`
--

LOCK TABLES `dieukienthamgiagiai_thanhtich` WRITE;
/*!40000 ALTER TABLE `dieukienthamgiagiai_thanhtich` DISABLE KEYS */;
/*!40000 ALTER TABLE `dieukienthamgiagiai_thanhtich` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dieulegiaidau`
--

DROP TABLE IF EXISTS `dieulegiaidau`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dieulegiaidau` (
  `iddieule` int(11) NOT NULL AUTO_INCREMENT,
  `idgiaidau` int(11) NOT NULL,
  `tieude` varchar(300) NOT NULL,
  `noidung` varchar(3000) DEFAULT NULL,
  `filedinhkem` varchar(500) DEFAULT NULL,
  `so_doi_toi_thieu` int(11) NOT NULL DEFAULT 2,
  `so_doi_toi_da` int(11) NOT NULL,
  `so_vdv_toi_thieu_moi_doi` int(11) NOT NULL DEFAULT 6,
  `so_vdv_toi_da_moi_doi` int(11) NOT NULL DEFAULT 14,
  `thoi_gian_mo_dang_ky` datetime DEFAULT NULL,
  `thoi_gian_dong_dang_ky` datetime DEFAULT NULL,
  `cho_phep_dang_ky_tu_do` tinyint(1) NOT NULL DEFAULT 1,
  `yeu_cau_duyet_dang_ky` tinyint(1) NOT NULL DEFAULT 1,
  `le_phi_tham_gia` decimal(12,2) NOT NULL DEFAULT 0.00,
  `quy_dinh_bo_cuoc` varchar(1000) DEFAULT NULL,
  `quy_dinh_khieu_nai` varchar(1000) DEFAULT NULL,
  `ngaytao` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`iddieule`),
  UNIQUE KEY `idgiaidau` (`idgiaidau`),
  CONSTRAINT `fk_dieule_giaidau` FOREIGN KEY (`idgiaidau`) REFERENCES `giaidau` (`idgiaidau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_dieule_doi` CHECK (`so_doi_toi_thieu` >= 2 and `so_doi_toi_da` >= `so_doi_toi_thieu`),
  CONSTRAINT `chk_dieule_time` CHECK (`thoi_gian_dong_dang_ky` is null or `thoi_gian_mo_dang_ky` is null or `thoi_gian_dong_dang_ky` >= `thoi_gian_mo_dang_ky`),
  CONSTRAINT `chk_dieule_vdv` CHECK (`so_vdv_toi_thieu_moi_doi` between 6 and 14 and `so_vdv_toi_da_moi_doi` between 6 and 14 and `so_vdv_toi_da_moi_doi` >= `so_vdv_toi_thieu_moi_doi`),
  CONSTRAINT `chk_dieule_lephi` CHECK (`le_phi_tham_gia` >= 0)
) ENGINE=InnoDB AUTO_INCREMENT=108 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dieulegiaidau`
--

LOCK TABLES `dieulegiaidau` WRITE;
/*!40000 ALTER TABLE `dieulegiaidau` DISABLE KEYS */;
INSERT INTO `dieulegiaidau` VALUES (105,105,'Điều lệ giải đấu TPHCM 2026','---VTMS_DIEU_LE_META---\n{\"le_phi_tham_gia\":\"0\",\"loai_doi_duoc_tham_gia\":\"\"}',NULL,2,4,6,14,NULL,NULL,1,1,0.00,NULL,NULL,'2026-05-19 00:32:32'),(107,106,'Điều lệ giải đấu','---VTMS_DIEU_LE_META---\n{\"le_phi_tham_gia\":\"0\",\"loai_doi_duoc_tham_gia\":\"\"}',NULL,2,10,6,14,NULL,NULL,1,1,0.00,NULL,NULL,'2026-05-19 21:34:36');
/*!40000 ALTER TABLE `dieulegiaidau` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `doibong`
--

DROP TABLE IF EXISTS `doibong`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `doibong` (
  `iddoibong` int(11) NOT NULL AUTO_INCREMENT,
  `tendoibong` varchar(300) NOT NULL,
  `logo` varchar(500) DEFAULT NULL,
  `idkhuvucdaidien` int(11) NOT NULL,
  `diaphuong` varchar(300) DEFAULT NULL,
  `mota` varchar(1000) DEFAULT NULL,
  `idhuanluyenvien` int(11) NOT NULL,
  `diem_xep_hang` decimal(10,2) NOT NULL DEFAULT 0.00,
  `trangthai` varchar(50) NOT NULL DEFAULT 'CHO_DUYET',
  `ngaytao` datetime NOT NULL DEFAULT current_timestamp(),
  `ngaycapnhat` datetime DEFAULT NULL,
  PRIMARY KEY (`iddoibong`),
  UNIQUE KEY `tendoibong` (`tendoibong`),
  KEY `fk_doibong_khuvuc` (`idkhuvucdaidien`),
  KEY `fk_doibong_hlv` (`idhuanluyenvien`),
  CONSTRAINT `fk_doibong_hlv` FOREIGN KEY (`idhuanluyenvien`) REFERENCES `huanluyenvien` (`idhuanluyenvien`) ON UPDATE CASCADE,
  CONSTRAINT `fk_doibong_khuvuc` FOREIGN KEY (`idkhuvucdaidien`) REFERENCES `khuvuc` (`idkhuvuc`) ON UPDATE CASCADE,
  CONSTRAINT `chk_doibong_trangthai` CHECK (`trangthai` in ('HOAT_DONG','CHO_DUYET','TAM_KHOA','GIAI_THE'))
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doibong`
--

LOCK TABLES `doibong` WRITE;
/*!40000 ALTER TABLE `doibong` DISABLE KEYS */;
INSERT INTO `doibong` VALUES (18,'Đội super Men',NULL,2,'TP. HCM','Màu áo: Xanh - Trắng',10,0.00,'HOAT_DONG','2026-05-18 15:10:51','2026-05-19 20:04:10'),(19,'Đội bóng Thủ đô',NULL,3,'Hà Lội','Đội bóng triển vọng Hà Lội suối\nMàu áo: Xanh - đỏ\nMàu áo: Xanh - đỏ',11,0.00,'HOAT_DONG','2026-05-19 13:14:20','2026-05-19 13:18:41');
/*!40000 ALTER TABLE `doibong` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `doidudieukienthamgia`
--

DROP TABLE IF EXISTS `doidudieukienthamgia`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `doidudieukienthamgia` (
  `iddieukien` int(11) NOT NULL AUTO_INCREMENT,
  `idgiaidau` int(11) NOT NULL,
  `iddoibong` int(11) NOT NULL,
  `iddieukienthamgia` int(11) DEFAULT NULL,
  `idsuat` int(11) DEFAULT NULL,
  `idthanhtich` int(11) DEFAULT NULL,
  `nguon_dieukien` varchar(50) NOT NULL,
  `lydo_dieukien` varchar(1000) DEFAULT NULL,
  `diem_xet_duyet` decimal(10,2) DEFAULT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'DU_DIEU_KIEN',
  `ngay_xac_nhan` datetime NOT NULL DEFAULT current_timestamp(),
  `idnguoixacnhan` int(11) DEFAULT NULL,
  `ghichu` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`iddieukien`),
  UNIQUE KEY `uq_ddk_giai_doi_v2` (`idgiaidau`,`iddoibong`),
  KEY `idx_ddk_giai_v2` (`idgiaidau`),
  KEY `idx_ddk_doi_v2` (`iddoibong`),
  KEY `idx_ddk_dktg_v2` (`iddieukienthamgia`),
  KEY `idx_ddk_suat_v2` (`idsuat`),
  KEY `idx_ddk_thanhtich_v2` (`idthanhtich`),
  KEY `idx_ddk_taikhoan_v2` (`idnguoixacnhan`),
  CONSTRAINT `fk_ddk_dktg_v2` FOREIGN KEY (`iddieukienthamgia`) REFERENCES `dieukienthamgiagiai` (`iddieukienthamgia`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_ddk_doi_v2` FOREIGN KEY (`iddoibong`) REFERENCES `doibong` (`iddoibong`) ON UPDATE CASCADE,
  CONSTRAINT `fk_ddk_giai_v2` FOREIGN KEY (`idgiaidau`) REFERENCES `giaidau` (`idgiaidau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_ddk_suat_v2` FOREIGN KEY (`idsuat`) REFERENCES `suatthamdu` (`idsuat`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_ddk_taikhoan_v2` FOREIGN KEY (`idnguoixacnhan`) REFERENCES `taikhoan` (`idtaikhoan`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_ddk_thanhtich_v2` FOREIGN KEY (`idthanhtich`) REFERENCES `thanhtichdoibong` (`idthanhtich`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_ddk_nguon_v2` CHECK (`nguon_dieukien` in ('THANH_TICH','XEP_HANG','SUAT_THAM_DU','BTC_CHON','DAC_CACH','DANG_KY_TU_DO')),
  CONSTRAINT `chk_ddk_trangthai_v2` CHECK (`trangthai` in ('DU_DIEU_KIEN','DA_MOI','DA_DANG_KY','DA_DUYET','TU_CHOI','HUY_TU_CACH','HET_HAN')),
  CONSTRAINT `chk_ddk_diem_v2` CHECK (`diem_xet_duyet` is null or `diem_xet_duyet` >= 0),
  CONSTRAINT `chk_ddk_source_required_v2` CHECK (`nguon_dieukien` = 'THANH_TICH' and `idthanhtich` is not null or `nguon_dieukien` = 'SUAT_THAM_DU' and `idsuat` is not null or `nguon_dieukien` in ('XEP_HANG','BTC_CHON','DAC_CACH','DANG_KY_TU_DO'))
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doidudieukienthamgia`
--

LOCK TABLES `doidudieukienthamgia` WRITE;
/*!40000 ALTER TABLE `doidudieukienthamgia` DISABLE KEYS */;
/*!40000 ALTER TABLE `doidudieukienthamgia` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_doidudieukien_bi_v2
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_doidudieukien_bu_v2
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `doihinh`
--

DROP TABLE IF EXISTS `doihinh`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `doihinh` (
  `iddoihinh` int(11) NOT NULL AUTO_INCREMENT,
  `iddoibong` int(11) NOT NULL,
  `idgiaidau` int(11) DEFAULT NULL,
  `tendoihinh` varchar(300) NOT NULL,
  `gioitinh` varchar(20) NOT NULL DEFAULT 'NAM',
  `la_doihinh_chinh` tinyint(1) NOT NULL DEFAULT 0,
  `trangthai` varchar(50) NOT NULL DEFAULT 'BAN_NHAP',
  `ngaytao` datetime NOT NULL DEFAULT current_timestamp(),
  `ngaycapnhat` datetime DEFAULT NULL,
  PRIMARY KEY (`iddoihinh`),
  KEY `idx_doihinh_doi` (`iddoibong`),
  KEY `idx_doihinh_giaidau` (`idgiaidau`),
  KEY `idx_doihinh_doi_ten` (`iddoibong`,`tendoihinh`),
  CONSTRAINT `fk_doihinh_doi` FOREIGN KEY (`iddoibong`) REFERENCES `doibong` (`iddoibong`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_doihinh_giaidau` FOREIGN KEY (`idgiaidau`) REFERENCES `giaidau` (`idgiaidau`) ON DELETE SET NULL,
  CONSTRAINT `chk_doihinh_trangthai` CHECK (`trangthai` in ('BAN_NHAP','DA_CHOT','DA_CAP_NHAT'))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doihinh`
--

LOCK TABLES `doihinh` WRITE;
/*!40000 ALTER TABLE `doihinh` DISABLE KEYS */;
INSERT INTO `doihinh` VALUES (3,18,NULL,'Đội hình chính','NAM',1,'DA_CHOT','2026-05-18 22:12:40','2026-05-19 20:04:29'),(4,19,NULL,'Đội hình chính','NAM',1,'DA_CHOT','2026-05-19 13:19:16','2026-05-19 21:08:21');
/*!40000 ALTER TABLE `doihinh` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `doitrongbang`
--

DROP TABLE IF EXISTS `doitrongbang`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `doitrongbang` (
  `iddoitrongbang` int(11) NOT NULL AUTO_INCREMENT,
  `idbangdau` int(11) NOT NULL,
  `iddoibong` int(11) NOT NULL,
  `seed_no` int(11) DEFAULT NULL,
  `trangthai` varchar(30) NOT NULL DEFAULT 'HOAT_DONG',
  `ngaythem` datetime NOT NULL DEFAULT current_timestamp(),
  `ngaycapnhat` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`iddoitrongbang`),
  UNIQUE KEY `uq_dtb` (`idbangdau`,`iddoibong`),
  UNIQUE KEY `uq_doitrongbang_seed` (`idbangdau`,`seed_no`),
  KEY `fk_dtb_doi` (`iddoibong`),
  KEY `idx_doitrongbang_bang_trangthai` (`idbangdau`,`trangthai`),
  CONSTRAINT `fk_dtb_bang` FOREIGN KEY (`idbangdau`) REFERENCES `bangdau` (`idbangdau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_dtb_doi` FOREIGN KEY (`iddoibong`) REFERENCES `doibong` (`iddoibong`) ON UPDATE CASCADE,
  CONSTRAINT `chk_doitrongbang_trangthai` CHECK (`trangthai` in ('HOAT_DONG','TAM_LOAI','DA_XOA'))
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doitrongbang`
--

LOCK TABLES `doitrongbang` WRITE;
/*!40000 ALTER TABLE `doitrongbang` DISABLE KEYS */;
/*!40000 ALTER TABLE `doitrongbang` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_doitrongbang_bi
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `doitrongvongdau`
--

DROP TABLE IF EXISTS `doitrongvongdau`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `doitrongvongdau` (
  `iddoitrongvong` int(11) NOT NULL AUTO_INCREMENT,
  `idvongdau` int(11) NOT NULL,
  `iddoibong` int(11) NOT NULL,
  `seed_no` int(11) DEFAULT NULL,
  `thuhang_vongtruoc` int(11) DEFAULT NULL,
  `nguonvao` varchar(100) NOT NULL DEFAULT 'DANG_KY',
  `trangthai` varchar(50) NOT NULL DEFAULT 'HOP_LE',
  `ngaythem` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`iddoitrongvong`),
  UNIQUE KEY `uq_dtvong` (`idvongdau`,`iddoibong`),
  UNIQUE KEY `uq_dtvong_seed` (`idvongdau`,`seed_no`),
  KEY `fk_dtvong_doi` (`iddoibong`),
  CONSTRAINT `fk_dtvong_doi` FOREIGN KEY (`iddoibong`) REFERENCES `doibong` (`iddoibong`) ON UPDATE CASCADE,
  CONSTRAINT `fk_dtvong_vong` FOREIGN KEY (`idvongdau`) REFERENCES `vongdau` (`idvongdau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_dtvong_seed` CHECK (`seed_no` is null or `seed_no` > 0),
  CONSTRAINT `chk_dtvong_nguon` CHECK (`nguonvao` in ('DANG_KY','BXH_VONG_TRUOC','BTC_CHON','HE_THONG_CHON','DAC_CACH')),
  CONSTRAINT `chk_dtvong_trangthai` CHECK (`trangthai` in ('HOP_LE','BI_LOAI','DI_TIEP','CHO_XAC_NHAN'))
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doitrongvongdau`
--

LOCK TABLES `doitrongvongdau` WRITE;
/*!40000 ALTER TABLE `doitrongvongdau` DISABLE KEYS */;
INSERT INTO `doitrongvongdau` VALUES (18,7,18,1,NULL,'DANG_KY','HOP_LE','2026-05-19 22:46:39'),(19,7,19,2,NULL,'DANG_KY','HOP_LE','2026-05-19 22:46:39');
/*!40000 ALTER TABLE `doitrongvongdau` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_doitrongvong_bi
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `donnghitrongtai`
--

DROP TABLE IF EXISTS `donnghitrongtai`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `donnghitrongtai` (
  `iddonnghi` int(11) NOT NULL AUTO_INCREMENT,
  `idtrongtai` int(11) NOT NULL,
  `tungay` date NOT NULL,
  `denngay` date NOT NULL,
  `lydo` varchar(1000) NOT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'CHO_DUYET',
  `ngaygui` datetime NOT NULL DEFAULT current_timestamp(),
  `ngayxuly` datetime DEFAULT NULL,
  PRIMARY KEY (`iddonnghi`),
  KEY `fk_dntt_trongtai` (`idtrongtai`),
  CONSTRAINT `fk_dntt_trongtai` FOREIGN KEY (`idtrongtai`) REFERENCES `trongtai` (`idtrongtai`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_dntt_ngay` CHECK (`denngay` >= `tungay`),
  CONSTRAINT `chk_dntt_xuly` CHECK (`ngayxuly` is null or `ngayxuly` >= `ngaygui`),
  CONSTRAINT `chk_dntt_trangthai` CHECK (`trangthai` in ('CHO_DUYET','DA_DUYET','TU_CHOI','DA_HUY'))
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `donnghitrongtai`
--

LOCK TABLES `donnghitrongtai` WRITE;
/*!40000 ALTER TABLE `donnghitrongtai` DISABLE KEYS */;
/*!40000 ALTER TABLE `donnghitrongtai` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `donnghivandongvien`
--

DROP TABLE IF EXISTS `donnghivandongvien`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `donnghivandongvien` (
  `iddonnghi` int(11) NOT NULL AUTO_INCREMENT,
  `idvandongvien` int(11) NOT NULL,
  `idtrandau` int(11) DEFAULT NULL,
  `tungay` date NOT NULL,
  `denngay` date NOT NULL,
  `lydo` varchar(1000) NOT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'CHO_DUYET',
  `ngaygui` datetime NOT NULL DEFAULT current_timestamp(),
  `ngayxuly` datetime DEFAULT NULL,
  `idnguoixuly` int(11) DEFAULT NULL,
  PRIMARY KEY (`iddonnghi`),
  KEY `fk_dnvdv_vdv` (`idvandongvien`),
  KEY `fk_dnvdv_tran` (`idtrandau`),
  KEY `fk_dnvdv_nguoixuly` (`idnguoixuly`),
  CONSTRAINT `fk_dnvdv_nguoixuly` FOREIGN KEY (`idnguoixuly`) REFERENCES `taikhoan` (`idtaikhoan`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_dnvdv_tran` FOREIGN KEY (`idtrandau`) REFERENCES `trandau` (`idtrandau`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_dnvdv_vdv` FOREIGN KEY (`idvandongvien`) REFERENCES `vandongvien` (`idvandongvien`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_dnvdv_ngay` CHECK (`denngay` >= `tungay`),
  CONSTRAINT `chk_dnvdv_xuly` CHECK (`ngayxuly` is null or `ngayxuly` >= `ngaygui`),
  CONSTRAINT `chk_dnvdv_trangthai` CHECK (`trangthai` in ('CHO_DUYET','DA_DUYET','TU_CHOI','DA_HUY'))
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `donnghivandongvien`
--

LOCK TABLES `donnghivandongvien` WRITE;
/*!40000 ALTER TABLE `donnghivandongvien` DISABLE KEYS */;
/*!40000 ALTER TABLE `donnghivandongvien` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `giaidau`
--

DROP TABLE IF EXISTS `giaidau`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `giaidau` (
  `idgiaidau` int(11) NOT NULL AUTO_INCREMENT,
  `tengiaidau` varchar(300) NOT NULL,
  `mota` varchar(1000) DEFAULT NULL,
  `idcapgiaidau` int(11) NOT NULL,
  `idkhuvucphamvi` int(11) NOT NULL,
  `idbantochuc` int(11) NOT NULL,
  `idluat` int(11) NOT NULL,
  `thoigianbatdau` date NOT NULL,
  `thoigianketthuc` date NOT NULL,
  `quymo` int(11) NOT NULL,
  `quymo_tu_dong` tinyint(1) NOT NULL DEFAULT 1,
  `quymo_ghi_chu` varchar(500) DEFAULT NULL,
  `hinhanh` varchar(500) DEFAULT NULL,
  `hinhanh_kieu` varchar(20) DEFAULT NULL,
  `hinhanh_ten_goc` varchar(255) DEFAULT NULL,
  `tinhchat` varchar(100) NOT NULL DEFAULT 'CHINH_THUC',
  `gioitinh` varchar(20) NOT NULL DEFAULT 'NAM',
  `trangthai` varchar(50) NOT NULL DEFAULT 'NHAP',
  `trangthaidangky` varchar(50) NOT NULL DEFAULT 'CHUA_MO',
  `trangthaithietlap` varchar(50) NOT NULL DEFAULT 'DANG_THIET_LAP',
  `ghichu_diadiem` varchar(500) DEFAULT NULL,
  `ngaytao` datetime NOT NULL DEFAULT current_timestamp(),
  `ngaycapnhat` datetime DEFAULT NULL,
  PRIMARY KEY (`idgiaidau`),
  UNIQUE KEY `uq_giaidau_ten_ngay` (`tengiaidau`,`thoigianbatdau`),
  KEY `idx_giaidau_cap_khuvuc` (`idcapgiaidau`,`idkhuvucphamvi`),
  KEY `fk_giaidau_khuvuc` (`idkhuvucphamvi`),
  KEY `fk_giaidau_btc` (`idbantochuc`),
  KEY `fk_giaidau_luat` (`idluat`),
  CONSTRAINT `fk_giaidau_btc` FOREIGN KEY (`idbantochuc`) REFERENCES `bantochuc` (`idbantochuc`) ON UPDATE CASCADE,
  CONSTRAINT `fk_giaidau_cap` FOREIGN KEY (`idcapgiaidau`) REFERENCES `capgiaidau` (`idcapgiaidau`) ON UPDATE CASCADE,
  CONSTRAINT `fk_giaidau_khuvuc` FOREIGN KEY (`idkhuvucphamvi`) REFERENCES `khuvuc` (`idkhuvuc`) ON UPDATE CASCADE,
  CONSTRAINT `fk_giaidau_luat` FOREIGN KEY (`idluat`) REFERENCES `luatthidau` (`idluat`) ON UPDATE CASCADE,
  CONSTRAINT `chk_giaidau_thoigian` CHECK (`thoigianketthuc` >= `thoigianbatdau`),
  CONSTRAINT `chk_giaidau_quymo` CHECK (`quymo` > 0),
  CONSTRAINT `chk_giaidau_tinhchat` CHECK (`tinhchat` in ('CHINH_THUC','GIAO_HUU','PHONG_TRAO','NOI_BO','MO_RONG')),
  CONSTRAINT `chk_giaidau_trangthai` CHECK (`trangthai` in ('NHAP','CHUA_CONG_BO','DA_CONG_BO','DANG_DIEN_RA','DA_KET_THUC','DA_HUY')),
  CONSTRAINT `chk_giaidau_dangky` CHECK (`trangthaidangky` in ('CHUA_MO','DANG_MO','DA_DONG')),
  CONSTRAINT `chk_giaidau_thietlap` CHECK (`trangthaithietlap` in ('DANG_THIET_LAP','DA_KHOA_DOI','DA_TAO_CAU_TRUC','DA_TAO_TRAN','DA_CONG_BO_LICH'))
) ENGINE=InnoDB AUTO_INCREMENT=107 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `giaidau`
--

LOCK TABLES `giaidau` WRITE;
/*!40000 ALTER TABLE `giaidau` DISABLE KEYS */;
INSERT INTO `giaidau` VALUES (105,'Giải TPHCM 2026',NULL,2,2,2,1,'2026-06-01','2026-06-04',4,1,NULL,'/uploads/tournaments/tournament_20260519_003232_dc92688113d4.jpg',NULL,NULL,'CHINH_THUC','NAM','DA_CONG_BO','DA_DONG','DANG_THIET_LAP',NULL,'2026-05-19 00:32:32','2026-05-19 13:48:29'),(106,'Giải quốc gia VN 2026','Giải đấu vô địch cúp Quốc gia Việt Nam, đội vô địch sẽ được đại diện cho quốc gia thi đấu giải Châu Á',1,1,1,1,'2026-06-01','2026-06-04',10,1,NULL,'/uploads/tournaments/tournament_20260519_200339_d6a43e0b8794.jpg',NULL,NULL,'CHINH_THUC','NAM','DA_CONG_BO','DA_DONG','DANG_THIET_LAP',NULL,'2026-05-19 20:03:39','2026-05-19 21:34:36');
/*!40000 ALTER TABLE `giaidau` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_giaidau_bi
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `huanluyenvien`
--

DROP TABLE IF EXISTS `huanluyenvien`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `huanluyenvien` (
  `idhuanluyenvien` int(11) NOT NULL AUTO_INCREMENT,
  `idnguoidung` int(11) NOT NULL,
  `idkhuvuccongtac` int(11) DEFAULT NULL,
  `donvicongtac` varchar(300) DEFAULT NULL,
  `bangcap` varchar(300) DEFAULT NULL,
  `kinhnghiem` int(11) NOT NULL DEFAULT 0,
  `trangthai` varchar(50) NOT NULL DEFAULT 'CHO_DUYET',
  PRIMARY KEY (`idhuanluyenvien`),
  UNIQUE KEY `idnguoidung` (`idnguoidung`),
  KEY `idx_hlv_khuvuccongtac` (`idkhuvuccongtac`),
  CONSTRAINT `fk_hlv_khuvuccongtac` FOREIGN KEY (`idkhuvuccongtac`) REFERENCES `khuvuc` (`idkhuvuc`) ON UPDATE CASCADE,
  CONSTRAINT `fk_hlv_nguoidung` FOREIGN KEY (`idnguoidung`) REFERENCES `nguoidung` (`idnguoidung`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_hlv_kinhnghiem` CHECK (`kinhnghiem` >= 0),
  CONSTRAINT `chk_hlv_trangthai` CHECK (`trangthai` in ('CHO_DUYET','DA_XAC_NHAN','BI_HUY_TU_CACH','NGUNG_HOAT_DONG'))
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `huanluyenvien`
--

LOCK TABLES `huanluyenvien` WRITE;
/*!40000 ALTER TABLE `huanluyenvien` DISABLE KEYS */;
INSERT INTO `huanluyenvien` VALUES (1,8,NULL,NULL,'HLV A',8,'DA_XAC_NHAN'),(2,9,NULL,NULL,'HLV A',7,'DA_XAC_NHAN'),(3,10,NULL,NULL,'HLV B',5,'DA_XAC_NHAN'),(4,11,NULL,NULL,'HLV B',5,'DA_XAC_NHAN'),(10,109,2,'Vũ trụ huyền bí','Đại học',4,'DA_XAC_NHAN'),(11,110,2,'9 tầng mây','Đại học',4,'DA_XAC_NHAN');
/*!40000 ALTER TABLE `huanluyenvien` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ketquatrandau`
--

DROP TABLE IF EXISTS `ketquatrandau`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ketquatrandau` (
  `idketqua` int(11) NOT NULL AUTO_INCREMENT,
  `idtrandau` int(11) NOT NULL,
  `iddoithang` int(11) DEFAULT NULL,
  `iddoithua` int(11) DEFAULT NULL,
  `diemdoi1` int(11) NOT NULL DEFAULT 0,
  `diemdoi2` int(11) NOT NULL DEFAULT 0,
  `sosetdoi1` int(11) NOT NULL DEFAULT 0,
  `sosetdoi2` int(11) NOT NULL DEFAULT 0,
  `trangthai` varchar(50) NOT NULL DEFAULT 'CHO_CONG_BO',
  `ngayghinhan` datetime NOT NULL DEFAULT current_timestamp(),
  `ngaycongbo` datetime DEFAULT NULL,
  `idnguoighinhan` int(11) DEFAULT NULL,
  PRIMARY KEY (`idketqua`),
  UNIQUE KEY `idtrandau` (`idtrandau`),
  KEY `fk_kqtd_doithang` (`iddoithang`),
  KEY `fk_kqtd_doithua` (`iddoithua`),
  KEY `fk_kqtd_nguoighinhan` (`idnguoighinhan`),
  CONSTRAINT `fk_kqtd_doithang` FOREIGN KEY (`iddoithang`) REFERENCES `doibong` (`iddoibong`) ON UPDATE CASCADE,
  CONSTRAINT `fk_kqtd_doithua` FOREIGN KEY (`iddoithua`) REFERENCES `doibong` (`iddoibong`) ON UPDATE CASCADE,
  CONSTRAINT `fk_kqtd_nguoighinhan` FOREIGN KEY (`idnguoighinhan`) REFERENCES `taikhoan` (`idtaikhoan`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_kqtd_tran` FOREIGN KEY (`idtrandau`) REFERENCES `trandau` (`idtrandau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_kqtd_diem` CHECK (`diemdoi1` >= 0 and `diemdoi2` >= 0 and `sosetdoi1` >= 0 and `sosetdoi2` >= 0),
  CONSTRAINT `chk_kqtd_set` CHECK (`sosetdoi1` <= 5 and `sosetdoi2` <= 5),
  CONSTRAINT `chk_kqtd_trangthai` CHECK (`trangthai` in ('CHO_CONG_BO','DA_CONG_BO','DA_DIEU_CHINH','BI_HUY')),
  CONSTRAINT `chk_kqtd_congbo` CHECK (`ngaycongbo` is null or `ngaycongbo` >= `ngayghinhan`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ketquatrandau`
--

LOCK TABLES `ketquatrandau` WRITE;
/*!40000 ALTER TABLE `ketquatrandau` DISABLE KEYS */;
/*!40000 ALTER TABLE `ketquatrandau` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_ketqua_bi
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_ketqua_ai
AFTER INSERT ON ketquatrandau
FOR EACH ROW
BEGIN
    UPDATE trandau
    SET trangthai = 'DA_KET_THUC', thoigianketthuc = COALESCE(thoigianketthuc, NEW.ngayghinhan), ngaycapnhat = CURRENT_TIMESTAMP
    WHERE idtrandau = NEW.idtrandau;
    CALL sp_cap_nhat_slot_tu_ketqua(NEW.idtrandau);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `khieunai`
--

DROP TABLE IF EXISTS `khieunai`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `khieunai` (
  `idkhieunai` int(11) NOT NULL AUTO_INCREMENT,
  `idnguoigui` int(11) NOT NULL,
  `idgiaidau` int(11) NOT NULL,
  `idtrandau` int(11) DEFAULT NULL,
  `tieude` varchar(300) NOT NULL,
  `noidung` varchar(2000) NOT NULL,
  `minhchung` varchar(500) DEFAULT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'CHO_TIEP_NHAN',
  `ngaygui` datetime NOT NULL DEFAULT current_timestamp(),
  `ngayxuly` datetime DEFAULT NULL,
  `idnguoixuly` int(11) DEFAULT NULL,
  PRIMARY KEY (`idkhieunai`),
  KEY `fk_khieunai_nguoigui` (`idnguoigui`),
  KEY `fk_khieunai_giaidau` (`idgiaidau`),
  KEY `fk_khieunai_tran` (`idtrandau`),
  KEY `fk_khieunai_nguoixuly` (`idnguoixuly`),
  CONSTRAINT `fk_khieunai_giaidau` FOREIGN KEY (`idgiaidau`) REFERENCES `giaidau` (`idgiaidau`) ON UPDATE CASCADE,
  CONSTRAINT `fk_khieunai_nguoigui` FOREIGN KEY (`idnguoigui`) REFERENCES `taikhoan` (`idtaikhoan`) ON UPDATE CASCADE,
  CONSTRAINT `fk_khieunai_nguoixuly` FOREIGN KEY (`idnguoixuly`) REFERENCES `taikhoan` (`idtaikhoan`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_khieunai_tran` FOREIGN KEY (`idtrandau`) REFERENCES `trandau` (`idtrandau`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_khieunai_trangthai` CHECK (`trangthai` in ('CHO_TIEP_NHAN','DANG_XU_LY','DA_XU_LY','TU_CHOI','KHONG_XU_LY')),
  CONSTRAINT `chk_khieunai_ngayxuly` CHECK (`ngayxuly` is null or `ngayxuly` >= `ngaygui`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `khieunai`
--

LOCK TABLES `khieunai` WRITE;
/*!40000 ALTER TABLE `khieunai` DISABLE KEYS */;
/*!40000 ALTER TABLE `khieunai` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `khuvuc`
--

DROP TABLE IF EXISTS `khuvuc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `khuvuc` (
  `idkhuvuc` int(11) NOT NULL AUTO_INCREMENT,
  `makhuvuc` varchar(100) NOT NULL,
  `tenkhuvuc` varchar(300) NOT NULL,
  `capkhuvuc` varchar(50) NOT NULL,
  `idkhuvuccha` int(11) DEFAULT NULL,
  `mota` varchar(1000) DEFAULT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'HOAT_DONG',
  `ngaytao` datetime NOT NULL DEFAULT current_timestamp(),
  `ngaycapnhat` datetime DEFAULT NULL,
  PRIMARY KEY (`idkhuvuc`),
  UNIQUE KEY `makhuvuc` (`makhuvuc`),
  KEY `fk_khuvuc_cha` (`idkhuvuccha`),
  KEY `idx_khuvuc_cap_cha_trangthai` (`capkhuvuc`,`idkhuvuccha`,`trangthai`),
  CONSTRAINT `fk_khuvuc_cha` FOREIGN KEY (`idkhuvuccha`) REFERENCES `khuvuc` (`idkhuvuc`) ON UPDATE CASCADE,
  CONSTRAINT `chk_khuvuc_cap` CHECK (`capkhuvuc` in ('QUOC_GIA','TINH_THANH','QUAN_HUYEN','XA_PHUONG','DON_VI')),
  CONSTRAINT `chk_khuvuc_trangthai` CHECK (`trangthai` in ('HOAT_DONG','NGUNG_SU_DUNG'))
) ENGINE=InnoDB AUTO_INCREMENT=1033 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `khuvuc`
--

LOCK TABLES `khuvuc` WRITE;
/*!40000 ALTER TABLE `khuvuc` DISABLE KEYS */;
INSERT INTO `khuvuc` VALUES (1,'VN','Việt Nam','QUOC_GIA',NULL,'Phạm vi quốc gia','HOAT_DONG','2026-05-17 16:49:33',NULL),(2,'HCM','TP. Hồ Chí Minh','TINH_THANH',1,'Tỉnh/thành thuộc Việt Nam','HOAT_DONG','2026-05-17 16:49:33',NULL),(3,'HN','Hà Nội','TINH_THANH',1,'Tỉnh/thành thuộc Việt Nam','HOAT_DONG','2026-05-17 16:49:33',NULL),(4,'DN','Đà Nẵng','TINH_THANH',1,'Tỉnh/thành thuộc Việt Nam','HOAT_DONG','2026-05-17 16:49:33',NULL),(5,'CT','Cần Thơ','TINH_THANH',1,'Tỉnh/thành thuộc Việt Nam','HOAT_DONG','2026-05-17 16:49:33',NULL),(10,'GV','Quận Gò Vấp','QUAN_HUYEN',2,'Quận/huyện thuộc TP.HCM','HOAT_DONG','2026-05-17 16:49:33',NULL),(11,'Q1','Quận 1','QUAN_HUYEN',2,'Quận/huyện thuộc TP.HCM','HOAT_DONG','2026-05-17 16:49:33',NULL),(12,'Q12','Quận 12','QUAN_HUYEN',2,'Quận/huyện thuộc TP.HCM','HOAT_DONG','2026-05-17 16:49:33',NULL),(13,'BT','Quận Bình Thạnh','QUAN_HUYEN',2,'Quận/huyện thuộc TP.HCM','HOAT_DONG','2026-05-17 16:49:33',NULL),(20,'P1_GV','Phường 1 - Gò Vấp','XA_PHUONG',10,'Xã/phường thuộc Gò Vấp','HOAT_DONG','2026-05-17 16:49:33',NULL),(21,'P3_GV','Phường 3 - Gò Vấp','XA_PHUONG',10,'Xã/phường thuộc Gò Vấp','HOAT_DONG','2026-05-17 16:49:33',NULL),(22,'P5_GV','Phường 5 - Gò Vấp','XA_PHUONG',10,'Xã/phường thuộc Gò Vấp','HOAT_DONG','2026-05-17 16:49:33',NULL),(23,'P25_BT','Phường 25 - Bình Thạnh','XA_PHUONG',13,'Xã/phường thuộc Bình Thạnh','HOAT_DONG','2026-05-17 16:49:33',NULL),(30,'IUH','Đại học Công nghiệp TP.HCM','DON_VI',20,'Đơn vị cơ sở','HOAT_DONG','2026-05-17 16:49:33',NULL),(31,'HUTECH','Đại học Công nghệ TP.HCM','DON_VI',23,'Đơn vị cơ sở','HOAT_DONG','2026-05-17 16:49:33',NULL),(40,'IUH_KCNTT','Khoa Công nghệ thông tin IUH','DON_VI',30,'Đơn vị trực thuộc IUH','HOAT_DONG','2026-05-17 16:49:33',NULL),(41,'IUH_KQTKD','Khoa Quản trị kinh doanh IUH','DON_VI',30,'Đơn vị trực thuộc IUH','HOAT_DONG','2026-05-17 16:49:33',NULL),(42,'IUH_KCK','Khoa Cơ khí IUH','DON_VI',30,'Đơn vị trực thuộc IUH','HOAT_DONG','2026-05-17 16:49:33',NULL),(1001,'P_BEN_NGHE_Q1','Phuong Ben Nghe - Quan 1','XA_PHUONG',11,'Xa/phuong thuoc Quan 1','HOAT_DONG','2026-05-17 16:49:43',NULL),(1002,'P_BEN_THANH_Q1','Phuong Ben Thanh - Quan 1','XA_PHUONG',11,'Xa/phuong thuoc Quan 1','HOAT_DONG','2026-05-17 16:49:43',NULL),(1012,'P_TCH_Q12','Phuong Tan Chanh Hiep - Quan 12','XA_PHUONG',12,'Xa/phuong thuoc Quan 12','HOAT_DONG','2026-05-17 16:49:43',NULL),(1013,'P_HT_Q12','Phuong Hiep Thanh - Quan 12','XA_PHUONG',12,'Xa/phuong thuoc Quan 12','HOAT_DONG','2026-05-17 16:49:43',NULL),(1026,'P_26_BT','Phuong 26 - Binh Thanh','XA_PHUONG',13,'Xa/phuong thuoc Binh Thanh','HOAT_DONG','2026-05-17 16:49:43',NULL),(1027,'HN_NTL','Quận Nam Từ Liêm','QUAN_HUYEN',3,'Quận/huyện thuộc Hà Nội','HOAT_DONG','2026-05-19 22:45:18',NULL),(1028,'HN_MD1','Phường Mỹ Đình 1','XA_PHUONG',1027,'Xã/phường thuộc Quận Nam Từ Liêm','HOAT_DONG','2026-05-19 22:45:18',NULL),(1029,'HN_CG','Quận Cầu Giấy','QUAN_HUYEN',3,'Quận/huyện thuộc Hà Nội','HOAT_DONG','2026-05-19 22:45:18',NULL),(1030,'HN_DV','Phường Dịch Vọng','XA_PHUONG',1029,'Xã/phường thuộc Quận Cầu Giấy','HOAT_DONG','2026-05-19 22:45:18',NULL),(1031,'HN_TH','Quận Tây Hồ','QUAN_HUYEN',3,'Quận/huyện thuộc Hà Nội','HOAT_DONG','2026-05-19 22:45:18',NULL),(1032,'HN_XL','Phường Xuân La','XA_PHUONG',1031,'Xã/phường thuộc Quận Tây Hồ','HOAT_DONG','2026-05-19 22:45:18',NULL);
/*!40000 ALTER TABLE `khuvuc` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_khuvuc_bi
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `lichsudangnhap`
--

DROP TABLE IF EXISTS `lichsudangnhap`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lichsudangnhap` (
  `idlichsu` int(11) NOT NULL AUTO_INCREMENT,
  `idtaikhoan` int(11) NOT NULL,
  `thoigian` datetime NOT NULL DEFAULT current_timestamp(),
  `ipaddress` varchar(100) DEFAULT NULL,
  `thietbi` varchar(300) DEFAULT NULL,
  `ketqua` varchar(50) NOT NULL,
  `ghichu` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`idlichsu`),
  KEY `fk_lsdn_taikhoan` (`idtaikhoan`),
  CONSTRAINT `fk_lsdn_taikhoan` FOREIGN KEY (`idtaikhoan`) REFERENCES `taikhoan` (`idtaikhoan`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_lsdn_ketqua` CHECK (`ketqua` in ('THANH_CONG','THAT_BAI'))
) ENGINE=InnoDB AUTO_INCREMENT=63 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lichsudangnhap`
--

LOCK TABLES `lichsudangnhap` WRITE;
/*!40000 ALTER TABLE `lichsudangnhap` DISABLE KEYS */;
INSERT INTO `lichsudangnhap` VALUES (20,3,'2026-05-18 13:24:22','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36 Edg/148.0.0.0','THANH_CONG','Dang nhap thanh cong'),(21,109,'2026-05-18 13:27:14','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36 Edg/148.0.0.0','THANH_CONG','Dang nhap thanh cong'),(22,109,'2026-05-18 13:29:54','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36 Edg/148.0.0.0','THANH_CONG','Dang nhap thanh cong'),(23,3,'2026-05-18 13:30:09','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36 Edg/148.0.0.0','THANH_CONG','Dang nhap thanh cong'),(24,109,'2026-05-18 13:47:47','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36 Edg/148.0.0.0','THANH_CONG','Dang nhap thanh cong'),(33,113,'2026-05-18 14:20:17','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','THANH_CONG','Dang nhap thanh cong'),(34,113,'2026-05-18 21:10:59','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','THANH_CONG','Dang nhap thanh cong'),(35,114,'2026-05-18 21:11:37','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','THANH_CONG','Dang nhap thanh cong'),(36,115,'2026-05-18 21:11:59','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','THANH_CONG','Dang nhap thanh cong'),(37,115,'2026-05-18 21:12:23','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','THANH_CONG','Dang nhap thanh cong'),(38,116,'2026-05-18 21:12:40','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','THANH_CONG','Dang nhap thanh cong'),(39,117,'2026-05-18 21:12:59','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','THANH_CONG','Dang nhap thanh cong'),(40,118,'2026-05-18 21:13:19','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','THANH_CONG','Dang nhap thanh cong'),(41,109,'2026-05-18 21:50:15','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36 Edg/148.0.0.0','THANH_CONG','Dang nhap thanh cong'),(42,3,'2026-05-19 00:30:10','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','THAT_BAI','Sai mat khau'),(43,3,'2026-05-19 00:30:14','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','THANH_CONG','Dang nhap thanh cong'),(44,109,'2026-05-19 00:32:47','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36 Edg/148.0.0.0','THANH_CONG','Dang nhap thanh cong'),(45,109,'2026-05-19 13:09:43','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','THANH_CONG','Dang nhap thanh cong'),(46,3,'2026-05-19 13:09:51','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36 Edg/148.0.0.0','THANH_CONG','Dang nhap thanh cong'),(47,110,'2026-05-19 13:12:24','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','THANH_CONG','Dang nhap thanh cong'),(48,2,'2026-05-19 13:48:39','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36 Edg/148.0.0.0','THANH_CONG','Dang nhap thanh cong'),(49,2,'2026-05-19 20:00:36','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36 Edg/148.0.0.0','THANH_CONG','Dang nhap thanh cong'),(50,109,'2026-05-19 20:00:48','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','THANH_CONG','Dang nhap thanh cong'),(51,109,'2026-05-19 20:18:48','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','THANH_CONG','Dang nhap thanh cong'),(52,110,'2026-05-19 21:07:51','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','THANH_CONG','Dang nhap thanh cong'),(53,6,'2026-05-19 22:47:16','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36 Edg/148.0.0.0','THANH_CONG','Dang nhap thanh cong'),(54,6,'2026-05-20 11:09:30','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36 Edg/148.0.0.0','THANH_CONG','Dang nhap thanh cong'),(55,6,'2026-05-20 13:46:01','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36 Edg/148.0.0.0','THANH_CONG','Dang nhap thanh cong'),(56,6,'2026-05-20 19:20:36','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.120.0 Chrome/142.0.7444.265 Electron/39.8.8 Safari/537.36','THANH_CONG','Dang nhap thanh cong'),(57,6,'2026-05-20 19:21:19','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36 Edg/148.0.0.0','THANH_CONG','Dang nhap thanh cong'),(58,7,'2026-05-20 19:44:14','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36 Edg/148.0.0.0','THANH_CONG','Dang nhap thanh cong'),(59,7,'2026-05-20 19:44:30','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36 Edg/148.0.0.0','THANH_CONG','Dang nhap thanh cong'),(60,6,'2026-05-20 19:44:41','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36 Edg/148.0.0.0','THANH_CONG','Dang nhap thanh cong'),(61,7,'2026-05-20 19:46:41','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36 Edg/148.0.0.0','THANH_CONG','Dang nhap thanh cong'),(62,6,'2026-05-20 21:13:50','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36 Edg/148.0.0.0','THANH_CONG','Dang nhap thanh cong');
/*!40000 ALTER TABLE `lichsudangnhap` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lichsumatkhau`
--

DROP TABLE IF EXISTS `lichsumatkhau`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lichsumatkhau` (
  `idlichsumatkhau` int(11) NOT NULL AUTO_INCREMENT,
  `idtaikhoan` int(11) NOT NULL,
  `passwordold` varchar(255) NOT NULL,
  `ngaythaydoi` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`idlichsumatkhau`),
  KEY `fk_lsmk_taikhoan` (`idtaikhoan`),
  CONSTRAINT `fk_lsmk_taikhoan` FOREIGN KEY (`idtaikhoan`) REFERENCES `taikhoan` (`idtaikhoan`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lichsumatkhau`
--

LOCK TABLES `lichsumatkhau` WRITE;
/*!40000 ALTER TABLE `lichsumatkhau` DISABLE KEYS */;
/*!40000 ALTER TABLE `lichsumatkhau` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lichsuthanhviendoibong`
--

DROP TABLE IF EXISTS `lichsuthanhviendoibong`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lichsuthanhviendoibong` (
  `idlichsu` int(11) NOT NULL AUTO_INCREMENT,
  `idthanhvien` int(11) NOT NULL,
  `hanhdong` varchar(100) NOT NULL,
  `ghichu` varchar(1000) DEFAULT NULL,
  `ngaythuchien` datetime NOT NULL DEFAULT current_timestamp(),
  `idnguoithuchien` int(11) DEFAULT NULL,
  PRIMARY KEY (`idlichsu`),
  KEY `fk_lstvdb_thanhvien` (`idthanhvien`),
  KEY `fk_lstvdb_taikhoan` (`idnguoithuchien`),
  CONSTRAINT `fk_lstvdb_taikhoan` FOREIGN KEY (`idnguoithuchien`) REFERENCES `taikhoan` (`idtaikhoan`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_lstvdb_thanhvien` FOREIGN KEY (`idthanhvien`) REFERENCES `thanhviendoibong` (`idthanhvien`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_lstvdb_hanhdong` CHECK (`hanhdong` in ('THEM_THANH_VIEN','XOA_THANH_VIEN','CHUYEN_DOI_THANH_VIEN','CAP_NHAT_VAI_TRO'))
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lichsuthanhviendoibong`
--

LOCK TABLES `lichsuthanhviendoibong` WRITE;
/*!40000 ALTER TABLE `lichsuthanhviendoibong` DISABLE KEYS */;
INSERT INTO `lichsuthanhviendoibong` VALUES (1,9,'THEM_THANH_VIEN','HLV them thanh vien vao doi bong','2026-05-18 21:11:18',109),(2,10,'THEM_THANH_VIEN','HLV them thanh vien vao doi bong','2026-05-18 21:11:48',109),(3,11,'THEM_THANH_VIEN','HLV them thanh vien vao doi bong','2026-05-18 21:12:15',109),(4,12,'THEM_THANH_VIEN','HLV them thanh vien vao doi bong','2026-05-18 21:12:51',109),(5,13,'THEM_THANH_VIEN','HLV them thanh vien vao doi bong','2026-05-18 21:13:07',109),(6,14,'THEM_THANH_VIEN','HLV them thanh vien vao doi bong','2026-05-18 21:13:33',109),(7,15,'THEM_THANH_VIEN','HLV tao tai khoan va them VDV vao doi bong','2026-05-19 13:15:27',110),(8,16,'THEM_THANH_VIEN','HLV tao tai khoan va them VDV vao doi bong','2026-05-19 13:16:30',110),(9,17,'THEM_THANH_VIEN','HLV tao tai khoan va them VDV vao doi bong','2026-05-19 13:16:46',110),(10,18,'THEM_THANH_VIEN','HLV tao tai khoan va them VDV vao doi bong','2026-05-19 13:16:59',110),(11,19,'THEM_THANH_VIEN','HLV tao tai khoan va them VDV vao doi bong','2026-05-19 13:17:11',110),(12,20,'THEM_THANH_VIEN','HLV tao tai khoan va them VDV vao doi bong','2026-05-19 13:17:23',110);
/*!40000 ALTER TABLE `lichsuthanhviendoibong` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `loimoidoibong`
--

DROP TABLE IF EXISTS `loimoidoibong`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `loimoidoibong` (
  `idloimoi` int(11) NOT NULL AUTO_INCREMENT,
  `iddoibong` int(11) NOT NULL,
  `idvandongvien` int(11) NOT NULL,
  `idhuanluyenvien` int(11) NOT NULL,
  `noidung` varchar(1000) DEFAULT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'CHO_PHAN_HOI',
  `ngaygui` datetime NOT NULL DEFAULT current_timestamp(),
  `ngayphanhoi` datetime DEFAULT NULL,
  `ngayhethan` datetime NOT NULL,
  PRIMARY KEY (`idloimoi`),
  KEY `fk_lmdb_doibong` (`iddoibong`),
  KEY `fk_lmdb_vdv` (`idvandongvien`),
  KEY `fk_lmdb_hlv` (`idhuanluyenvien`),
  CONSTRAINT `fk_lmdb_doibong` FOREIGN KEY (`iddoibong`) REFERENCES `doibong` (`iddoibong`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_lmdb_hlv` FOREIGN KEY (`idhuanluyenvien`) REFERENCES `huanluyenvien` (`idhuanluyenvien`) ON UPDATE CASCADE,
  CONSTRAINT `fk_lmdb_vdv` FOREIGN KEY (`idvandongvien`) REFERENCES `vandongvien` (`idvandongvien`) ON UPDATE CASCADE,
  CONSTRAINT `chk_lmdb_trangthai` CHECK (`trangthai` in ('CHO_PHAN_HOI','DONG_Y','TU_CHOI','HET_HAN')),
  CONSTRAINT `chk_lmdb_han` CHECK (`ngayhethan` >= `ngaygui`),
  CONSTRAINT `chk_lmdb_phanhoi` CHECK (`ngayphanhoi` is null or `ngayphanhoi` >= `ngaygui`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `loimoidoibong`
--

LOCK TABLES `loimoidoibong` WRITE;
/*!40000 ALTER TABLE `loimoidoibong` DISABLE KEYS */;
/*!40000 ALTER TABLE `loimoidoibong` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `luatthidau`
--

DROP TABLE IF EXISTS `luatthidau`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `luatthidau` (
  `idluat` int(11) NOT NULL AUTO_INCREMENT,
  `tenluat` varchar(300) NOT NULL,
  `phienban` varchar(100) DEFAULT NULL,
  `so_vdv_thi_dau` int(11) NOT NULL DEFAULT 6,
  `so_vdv_du_bi` int(11) NOT NULL DEFAULT 6,
  `tong_vdv_toi_da` int(11) NOT NULL DEFAULT 12,
  `kieu_tran` varchar(20) NOT NULL DEFAULT 'BO5',
  `so_set_thang_tran` int(11) NOT NULL DEFAULT 3,
  `diem_set_thuong` int(11) NOT NULL DEFAULT 25,
  `diem_set_quyet_dinh` int(11) NOT NULL DEFAULT 15,
  `cach_biet_toi_thieu` int(11) NOT NULL DEFAULT 2,
  `noidung_mota` varchar(3000) DEFAULT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'HOAT_DONG',
  PRIMARY KEY (`idluat`),
  CONSTRAINT `chk_luat_kieu` CHECK (`kieu_tran` in ('BO3','BO5')),
  CONSTRAINT `chk_luat_soluong` CHECK (`so_vdv_thi_dau` > 0 and `so_vdv_du_bi` >= 0 and `tong_vdv_toi_da` >= `so_vdv_thi_dau`),
  CONSTRAINT `chk_luat_set` CHECK (`so_set_thang_tran` in (2,3) and `diem_set_thuong` > 0 and `diem_set_quyet_dinh` > 0 and `cach_biet_toi_thieu` > 0),
  CONSTRAINT `chk_luat_trangthai` CHECK (`trangthai` in ('HOAT_DONG','NGUNG_SU_DUNG'))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `luatthidau`
--

LOCK TABLES `luatthidau` WRITE;
/*!40000 ALTER TABLE `luatthidau` DISABLE KEYS */;
INSERT INTO `luatthidau` VALUES (1,'Luật bóng chuyền trong nhà 6 người - BO5','VTMS-2026',6,6,12,'BO5',3,25,15,2,'Mẫu luật mặc định cho giải chính thức','HOAT_DONG'),(2,'Luật bóng chuyền trong nhà 6 người - BO3','VTMS-2026',6,6,12,'BO3',2,25,15,2,'Mẫu luật rút gọn cho giải phong trào','HOAT_DONG');
/*!40000 ALTER TABLE `luatthidau` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `nguoidung`
--

DROP TABLE IF EXISTS `nguoidung`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nguoidung` (
  `idnguoidung` int(11) NOT NULL AUTO_INCREMENT,
  `idtaikhoan` int(11) NOT NULL,
  `ten` varchar(100) NOT NULL,
  `hodem` varchar(200) NOT NULL,
  `gioitinh` varchar(20) NOT NULL,
  `ngaysinh` date DEFAULT NULL,
  `quequan` varchar(500) DEFAULT NULL,
  `diachi` varchar(500) DEFAULT NULL,
  `avatar` varchar(500) DEFAULT NULL,
  `cccd` varchar(20) DEFAULT NULL,
  `ngaytao` datetime NOT NULL DEFAULT current_timestamp(),
  `ngaycapnhat` datetime DEFAULT NULL,
  PRIMARY KEY (`idnguoidung`),
  UNIQUE KEY `idtaikhoan` (`idtaikhoan`),
  UNIQUE KEY `cccd` (`cccd`),
  CONSTRAINT `fk_nguoidung_taikhoan` FOREIGN KEY (`idtaikhoan`) REFERENCES `taikhoan` (`idtaikhoan`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_nguoidung_gioitinh` CHECK (`gioitinh` in ('NAM','NU','KHAC'))
) ENGINE=InnoDB AUTO_INCREMENT=125 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nguoidung`
--

LOCK TABLES `nguoidung` WRITE;
/*!40000 ALTER TABLE `nguoidung` DISABLE KEYS */;
INSERT INTO `nguoidung` VALUES (1,1,'Admin','Nguyễn','NAM','1990-01-01','Việt Nam','TP.HCM',NULL,'001000000001','2026-05-17 16:49:33',NULL),(2,2,'Quốc Gia','Trần','NAM','1985-02-01','Việt Nam','Hà Nội',NULL,'001000000002','2026-05-17 16:49:33',NULL),(3,3,'Hồ Chí Minh','Lê','NU','1988-03-01','TP.HCM','TP.HCM',NULL,'001000000003','2026-05-17 16:49:33',NULL),(4,4,'Gò Vấp','Phạm','NAM','1987-04-01','TP.HCM','Gò Vấp',NULL,'001000000004','2026-05-17 16:49:33',NULL),(5,5,'IUH','Võ','NU','1989-05-01','TP.HCM','IUH',NULL,'001000000005','2026-05-17 16:49:33',NULL),(6,6,'Trọng Tài Một','Đỗ','NAM','1980-06-01','TP.HCM','TP.HCM',NULL,'001000000006','2026-05-17 16:49:33',NULL),(7,7,'Trọng Tài Hai','Bùi','NU','1982-07-01','TP.HCM','TP.HCM',NULL,'001000000007','2026-05-17 16:49:33',NULL),(8,8,'HLV HCM','Ngô','NAM','1981-08-01','TP.HCM','TP.HCM',NULL,'001000000008','2026-05-17 16:49:33',NULL),(9,9,'HLV Hà Nội','Đặng','NAM','1983-09-01','Hà Nội','Hà Nội',NULL,'001000000009','2026-05-17 16:49:33',NULL),(10,10,'HLV Đà Nẵng','Hoàng','NU','1984-10-01','Đà Nẵng','Đà Nẵng',NULL,'001000000010','2026-05-17 16:49:33',NULL),(11,11,'HLV Cần Thơ','Phan','NAM','1986-11-01','Cần Thơ','Cần Thơ',NULL,'001000000011','2026-05-17 16:49:33',NULL),(12,12,'VĐV Một','Vũ','NAM','2002-01-01','TP.HCM','TP.HCM',NULL,'001000000012','2026-05-17 16:49:33',NULL),(13,13,'VĐV Hai','Mai','NU','2002-02-01','TP.HCM','TP.HCM',NULL,'001000000013','2026-05-17 16:49:33',NULL),(14,14,'VĐV Ba','Dương','NAM','2001-03-01','Hà Nội','Hà Nội',NULL,'001000000014','2026-05-17 16:49:33',NULL),(15,15,'VĐV Bốn','Tạ','NAM','2001-04-01','Đà Nẵng','Đà Nẵng',NULL,'001000000015','2026-05-17 16:49:33',NULL),(16,16,'VĐV Năm','Lý','NU','2003-05-01','Cần Thơ','Cần Thơ',NULL,'001000000016','2026-05-17 16:49:33',NULL),(17,17,'VĐV Sáu','Cao','NAM','2000-06-01','TP.HCM','Gò Vấp',NULL,'001000000017','2026-05-17 16:49:33',NULL),(18,18,'VĐV Bảy','Hồ','NAM','2000-07-01','TP.HCM','IUH',NULL,'001000000018','2026-05-17 16:49:33',NULL),(19,19,'VĐV Tám','Tô','NU','2000-08-01','TP.HCM','IUH',NULL,'001000000019','2026-05-17 16:49:33',NULL),(101,101,'BTC Quan 1','Nguyen','NAM','1985-01-01','TP.HCM','Quan 1',NULL,'001000000101','2026-05-17 16:49:43',NULL),(102,102,'BTC Quan 12','Nguyen','NAM','1985-01-02','TP.HCM','Quan 12',NULL,'001000000102','2026-05-17 16:49:43',NULL),(103,103,'BTC Binh Thanh','Nguyen','NU','1985-01-03','TP.HCM','Binh Thanh',NULL,'001000000103','2026-05-17 16:49:43',NULL),(109,109,'Bảo','Nguyễn Phú','NAM','2004-03-07',NULL,NULL,NULL,'040204008977','2026-05-18 13:23:36',NULL),(110,110,'Nhi','Lê Thị Yến','NU','2004-01-31',NULL,NULL,NULL,'040204008978','2026-05-18 13:26:33',NULL),(113,113,'A','Thành viên','NAM','2006-01-01',NULL,NULL,NULL,NULL,'2026-05-18 14:09:45',NULL),(114,114,'B','Thành viên','NAM','2006-01-01',NULL,NULL,NULL,NULL,'2026-05-18 14:10:31',NULL),(115,115,'C','Thành viên','NAM','2006-01-01',NULL,NULL,NULL,NULL,'2026-05-18 14:10:52',NULL),(116,116,'D','Thành viên','NAM','2006-01-01',NULL,NULL,NULL,NULL,'2026-05-18 14:11:07',NULL),(117,117,'E','Thành viên','NAM','2006-01-01',NULL,NULL,NULL,NULL,'2026-05-18 14:11:21',NULL),(118,118,'F','Thành viên','NAM','2006-01-01',NULL,NULL,NULL,NULL,'2026-05-18 14:11:36',NULL),(119,119,'1','Thành viên','NAM','2006-01-01',NULL,NULL,NULL,NULL,'2026-05-19 13:15:27',NULL),(120,120,'2','Thành viên','NAM','2006-01-01',NULL,NULL,NULL,NULL,'2026-05-19 13:16:30',NULL),(121,121,'3','Thành viên','NAM','2006-01-01',NULL,NULL,NULL,NULL,'2026-05-19 13:16:46',NULL),(122,122,'4','Thành viên','NAM','2006-01-01',NULL,NULL,NULL,NULL,'2026-05-19 13:16:59',NULL),(123,123,'5','Thành viên','NAM','2006-01-01',NULL,NULL,NULL,NULL,'2026-05-19 13:17:11',NULL),(124,124,'6','Thành viên','NAM','2006-01-01',NULL,NULL,NULL,NULL,'2026-05-19 13:17:23',NULL);
/*!40000 ALTER TABLE `nguoidung` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `nhatkyhethong`
--

DROP TABLE IF EXISTS `nhatkyhethong`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nhatkyhethong` (
  `idnhatky` int(11) NOT NULL AUTO_INCREMENT,
  `idtaikhoan` int(11) DEFAULT NULL,
  `hanhdong` varchar(300) NOT NULL,
  `bangtacdong` varchar(100) NOT NULL,
  `iddoituong` int(11) DEFAULT NULL,
  `thoigian` datetime NOT NULL DEFAULT current_timestamp(),
  `ipaddress` varchar(100) DEFAULT NULL,
  `ghichu` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`idnhatky`),
  KEY `fk_nkht_taikhoan` (`idtaikhoan`),
  CONSTRAINT `fk_nkht_taikhoan` FOREIGN KEY (`idtaikhoan`) REFERENCES `taikhoan` (`idtaikhoan`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=287 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nhatkyhethong`
--

LOCK TABLES `nhatkyhethong` WRITE;
/*!40000 ALTER TABLE `nhatkyhethong` DISABLE KEYS */;
INSERT INTO `nhatkyhethong` VALUES (21,NULL,'Dang ky tai khoan huan luyen vien','Taikhoan',104,'2026-05-18 11:44:19','::1','HLV \"Nguyễn Phú Bảo\" dang ky tai khoan, gui yeu cau xac nhan tu cach den BTC #1.'),(22,NULL,'Tao ho so huan luyen vien cho duyet','Huanluyenvien',5,'2026-05-18 11:44:19','::1','HLV \"Nguyễn Phú Bảo\" dang ky tai khoan, gui yeu cau xac nhan tu cach den BTC #1.'),(23,NULL,'Gui yeu cau xac nhan tu cach huan luyen vien','Yeucauxacnhan',2,'2026-05-18 11:44:19','::1','HLV \"Nguyễn Phú Bảo\" dang ky tai khoan, gui yeu cau xac nhan tu cach den BTC #1.'),(36,109,'Dang ky tai khoan huan luyen vien','Taikhoan',109,'2026-05-18 13:23:36','::1','HLV \"Nguyễn Phú Bảo\" dang ky tai khoan tai khu vuc #2, gui yeu cau xac nhan tu cach den BTC #2.'),(37,109,'Tao ho so huan luyen vien cho duyet','Huanluyenvien',10,'2026-05-18 13:23:36','::1','HLV \"Nguyễn Phú Bảo\" dang ky tai khoan tai khu vuc #2, gui yeu cau xac nhan tu cach den BTC #2.'),(38,109,'Gui yeu cau xac nhan tu cach huan luyen vien','Yeucauxacnhan',7,'2026-05-18 13:23:36','::1','HLV \"Nguyễn Phú Bảo\" dang ky tai khoan tai khu vuc #2, gui yeu cau xac nhan tu cach den BTC #2.'),(39,3,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-18 13:24:22','::1','Tai khoan #3 role BAN_TO_CHUC xem trang chu.'),(40,3,'Xac nhan tu cach huan luyen vien','Huanluyenvien',10,'2026-05-18 13:24:39','::1','Ban to chuc #2 xac nhan tu cach HLV #10 \"Nguyễn Phú Bảo\".'),(41,110,'Dang ky tai khoan huan luyen vien','Taikhoan',110,'2026-05-18 13:26:33','::1','HLV \"Lê Thị Yến Nhi\" dang ky tai khoan tai khu vuc #2, gui yeu cau xac nhan tu cach den BTC #2.'),(42,110,'Tao ho so huan luyen vien cho duyet','Huanluyenvien',11,'2026-05-18 13:26:33','::1','HLV \"Lê Thị Yến Nhi\" dang ky tai khoan tai khu vuc #2, gui yeu cau xac nhan tu cach den BTC #2.'),(43,110,'Gui yeu cau xac nhan tu cach huan luyen vien','Yeucauxacnhan',8,'2026-05-18 13:26:33','::1','HLV \"Lê Thị Yến Nhi\" dang ky tai khoan tai khu vuc #2, gui yeu cau xac nhan tu cach den BTC #2.'),(44,3,'Xac nhan tu cach huan luyen vien','Huanluyenvien',11,'2026-05-18 13:26:54','::1','Ban to chuc #2 xac nhan tu cach HLV #11 \"Lê Thị Yến Nhi\".'),(45,109,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-18 13:27:14','::1','Tai khoan #109 role HUAN_LUYEN_VIEN xem trang chu.'),(49,109,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-18 13:29:46','::1','Tai khoan #109 role HUAN_LUYEN_VIEN xem trang chu.'),(50,109,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-18 13:29:54','::1','Tai khoan #109 role HUAN_LUYEN_VIEN xem trang chu.'),(51,3,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-18 13:30:09','::1','Tai khoan #3 role BAN_TO_CHUC xem trang chu.'),(54,3,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-18 13:47:40','::1','Tai khoan #3 role BAN_TO_CHUC xem trang chu.'),(55,109,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-18 13:47:47','::1','Tai khoan #109 role HUAN_LUYEN_VIEN xem trang chu.'),(56,109,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-18 14:08:21','::1','Tai khoan #109 role HUAN_LUYEN_VIEN xem trang chu.'),(57,109,'Tao tai khoan van dong vien','Taikhoan',113,'2026-05-18 14:09:45','::1','HLV #10 tao truc tiep tai khoan VDV \"Thành viên A\".'),(58,109,'Tao ho so van dong vien','Vandongvien',11,'2026-05-18 14:09:45','::1','HLV #10 tao truc tiep tai khoan VDV \"Thành viên A\".'),(59,109,'Tao tai khoan van dong vien','Taikhoan',114,'2026-05-18 14:10:31','::1','HLV #10 tao truc tiep tai khoan VDV \"Thành viên B\".'),(60,109,'Tao ho so van dong vien','Vandongvien',12,'2026-05-18 14:10:31','::1','HLV #10 tao truc tiep tai khoan VDV \"Thành viên B\".'),(61,109,'Tao tai khoan van dong vien','Taikhoan',115,'2026-05-18 14:10:52','::1','HLV #10 tao truc tiep tai khoan VDV \"Thành viên C\".'),(62,109,'Tao ho so van dong vien','Vandongvien',13,'2026-05-18 14:10:52','::1','HLV #10 tao truc tiep tai khoan VDV \"Thành viên C\".'),(63,109,'Tao tai khoan van dong vien','Taikhoan',116,'2026-05-18 14:11:07','::1','HLV #10 tao truc tiep tai khoan VDV \"Thành viên D\".'),(64,109,'Tao ho so van dong vien','Vandongvien',14,'2026-05-18 14:11:07','::1','HLV #10 tao truc tiep tai khoan VDV \"Thành viên D\".'),(65,109,'Tao tai khoan van dong vien','Taikhoan',117,'2026-05-18 14:11:21','::1','HLV #10 tao truc tiep tai khoan VDV \"Thành viên E\".'),(66,109,'Tao ho so van dong vien','Vandongvien',15,'2026-05-18 14:11:21','::1','HLV #10 tao truc tiep tai khoan VDV \"Thành viên E\".'),(67,109,'Tao tai khoan van dong vien','Taikhoan',118,'2026-05-18 14:11:36','::1','HLV #10 tao truc tiep tai khoan VDV \"Thành viên F\".'),(68,109,'Tao ho so van dong vien','Vandongvien',16,'2026-05-18 14:11:36','::1','HLV #10 tao truc tiep tai khoan VDV \"Thành viên F\".'),(69,113,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-18 14:20:17','::1','Tai khoan #113 role VAN_DONG_VIEN xem trang chu.'),(70,113,'Xem danh sach loi moi doi bong','Loimoidoibong',NULL,'2026-05-18 14:20:21','::1','VDV #11 xem 0 loi moi doi bong.'),(71,113,'Xem danh sach doi bong cua VDV','Doibong',NULL,'2026-05-18 14:20:23','::1','VDV #11 xem 0 doi bong.'),(72,113,'Xem danh sach don nghi phep thi dau VDV','Donnghivandongvien',NULL,'2026-05-18 14:20:26','::1','VDV #11 xem 0 don nghi phep thi dau.'),(73,113,'Xem lich thi dau ca nhan','Trandau',NULL,'2026-05-18 14:20:26','::1','VDV #11 xem 0 tran dau trong lich ca nhan.'),(74,113,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-18 14:20:27','::1','Tai khoan #113 role VAN_DONG_VIEN xem trang chu.'),(75,113,'Xem danh sach yeu cau sua id ca nhan VDV','Yeucaucapnhathoso',NULL,'2026-05-18 14:20:35','::1','VDV #11 xem 0 yeu cau sua id ca nhan.'),(78,109,'Tao doi bong','Doibong',18,'2026-05-18 15:10:51','::1','HLV #10 tao doi bong \"Đội super Men\".'),(79,113,'Xem danh sach yeu cau sua id ca nhan VDV','Yeucaucapnhathoso',NULL,'2026-05-18 15:11:45','::1','VDV #11 xem 0 yeu cau sua id ca nhan.'),(80,113,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-18 21:10:59','::1','Tai khoan #113 role VAN_DONG_VIEN xem trang chu.'),(81,113,'Xem lich thi dau ca nhan','Trandau',NULL,'2026-05-18 21:11:06','::1','VDV #11 xem 0 tran dau trong lich ca nhan.'),(82,113,'Xem danh sach don nghi phep thi dau VDV','Donnghivandongvien',NULL,'2026-05-18 21:11:06','::1','VDV #11 xem 0 don nghi phep thi dau.'),(83,113,'Xem danh sach yeu cau sua id ca nhan VDV','Yeucaucapnhathoso',NULL,'2026-05-18 21:11:07','::1','VDV #11 xem 0 yeu cau sua id ca nhan.'),(84,109,'Them thanh vien doi bong','Thanhviendoibong',9,'2026-05-18 21:11:18','::1','HLV #10 them VDV #11 vao doi #18 \"Đội super Men\".'),(85,114,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-18 21:11:37','::1','Tai khoan #114 role VAN_DONG_VIEN xem trang chu.'),(86,114,'Xem danh sach yeu cau sua id ca nhan VDV','Yeucaucapnhathoso',NULL,'2026-05-18 21:11:41','::1','VDV #12 xem 0 yeu cau sua id ca nhan.'),(87,109,'Them thanh vien doi bong','Thanhviendoibong',10,'2026-05-18 21:11:48','::1','HLV #10 them VDV #12 vao doi #18 \"Đội super Men\".'),(88,115,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-18 21:11:59','::1','Tai khoan #115 role VAN_DONG_VIEN xem trang chu.'),(89,115,'Xem danh sach yeu cau sua id ca nhan VDV','Yeucaucapnhathoso',NULL,'2026-05-18 21:12:04','::1','VDV #13 xem 0 yeu cau sua id ca nhan.'),(90,109,'Them thanh vien doi bong','Thanhviendoibong',11,'2026-05-18 21:12:15','::1','HLV #10 them VDV #13 vao doi #18 \"Đội super Men\".'),(91,115,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-18 21:12:23','::1','Tai khoan #115 role VAN_DONG_VIEN xem trang chu.'),(92,115,'Xem danh sach yeu cau sua id ca nhan VDV','Yeucaucapnhathoso',NULL,'2026-05-18 21:12:25','::1','VDV #13 xem 0 yeu cau sua id ca nhan.'),(93,116,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-18 21:12:40','::1','Tai khoan #116 role VAN_DONG_VIEN xem trang chu.'),(94,116,'Xem danh sach yeu cau sua id ca nhan VDV','Yeucaucapnhathoso',NULL,'2026-05-18 21:12:43','::1','VDV #14 xem 0 yeu cau sua id ca nhan.'),(95,109,'Them thanh vien doi bong','Thanhviendoibong',12,'2026-05-18 21:12:51','::1','HLV #10 them VDV #14 vao doi #18 \"Đội super Men\".'),(96,117,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-18 21:12:59','::1','Tai khoan #117 role VAN_DONG_VIEN xem trang chu.'),(97,117,'Xem danh sach yeu cau sua id ca nhan VDV','Yeucaucapnhathoso',NULL,'2026-05-18 21:13:02','::1','VDV #15 xem 0 yeu cau sua id ca nhan.'),(98,109,'Them thanh vien doi bong','Thanhviendoibong',13,'2026-05-18 21:13:07','::1','HLV #10 them VDV #15 vao doi #18 \"Đội super Men\".'),(99,118,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-18 21:13:19','::1','Tai khoan #118 role VAN_DONG_VIEN xem trang chu.'),(100,118,'Xem danh sach yeu cau sua id ca nhan VDV','Yeucaucapnhathoso',NULL,'2026-05-18 21:13:29','::1','VDV #16 xem 0 yeu cau sua id ca nhan.'),(101,109,'Them thanh vien doi bong','Thanhviendoibong',14,'2026-05-18 21:13:33','::1','HLV #10 them VDV #16 vao doi #18 \"Đội super Men\".'),(102,118,'Xem danh sach loi moi doi bong','Loimoidoibong',NULL,'2026-05-18 21:37:07','::1','VDV #16 xem 0 loi moi doi bong.'),(103,118,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-18 21:37:09','::1','Tai khoan #118 role VAN_DONG_VIEN xem trang chu.'),(104,118,'Xem danh sach loi moi doi bong','Loimoidoibong',NULL,'2026-05-18 21:37:22','::1','VDV #16 xem 0 loi moi doi bong.'),(105,118,'Xem danh sach doi bong cua VDV','Doibong',NULL,'2026-05-18 21:37:23','::1','VDV #16 xem 1 doi bong.'),(106,118,'Xem thong tin doi bong','Doibong',18,'2026-05-18 21:37:23','::1','VDV #16 xem doi bong #18.'),(107,118,'Xem danh sach doi hinh','Doihinh',NULL,'2026-05-18 21:37:33','::1','VDV #16 xem 0 doi hinh.'),(108,118,'Xem lich thi dau ca nhan','Trandau',NULL,'2026-05-18 21:37:34','::1','VDV #16 xem 0 tran dau trong lich ca nhan.'),(109,118,'Xem danh sach doi hinh','Doihinh',NULL,'2026-05-18 21:37:36','::1','VDV #16 xem 0 doi hinh.'),(110,118,'Xem lich thi dau ca nhan','Trandau',NULL,'2026-05-18 21:37:38','::1','VDV #16 xem 0 tran dau trong lich ca nhan.'),(111,118,'Xem thong ke ca nhan VDV','Thongkecanhan',NULL,'2026-05-18 21:37:40','::1','VDV #16 xem thong ke ca nhan. So dong: 0.'),(112,118,'Xem danh sach yeu cau sua id ca nhan VDV','Yeucaucapnhathoso',NULL,'2026-05-18 21:37:55','::1','VDV #16 xem 0 yeu cau sua id ca nhan.'),(113,118,'Xem lich thi dau ca nhan','Trandau',NULL,'2026-05-18 21:38:05','::1','VDV #16 xem 0 tran dau trong lich ca nhan.'),(114,118,'Xem danh sach don nghi phep thi dau VDV','Donnghivandongvien',NULL,'2026-05-18 21:38:05','::1','VDV #16 xem 0 don nghi phep thi dau.'),(115,109,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-18 21:50:15','::1','Tai khoan #109 role HUAN_LUYEN_VIEN xem trang chu.'),(116,109,'Tao doi hinh','Doihinh',3,'2026-05-18 22:12:40','::1','HLV #10 tao doi hinh \"Đội hình chính (Nam)\" cho doi #18.'),(117,109,'Xem lich thi dau doi bong','Trandau',NULL,'2026-05-18 22:13:41','::1','HLV #10 xem lich thi dau doi #18 \"Đội super Men\". So tran: 0.'),(118,109,'Cap nhat doi hinh','Doihinh',3,'2026-05-19 00:29:00','::1','HLV #10 cap nhat doi hinh #3 \"Đội hình chính (Nam)\".'),(119,118,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-19 00:29:45','::1','Tai khoan #118 role VAN_DONG_VIEN xem trang chu.'),(120,3,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-19 00:30:14','::1','Tai khoan #3 role BAN_TO_CHUC xem trang chu.'),(121,3,'Tao giai dau','Giaidau',105,'2026-05-19 00:32:32','::1','Ban to chuc #2 tao giai dau \"Giải TPHCM 2026\" theo cap #2, khu vuc #2.'),(122,3,'Cong bo giai dau','Giaidau',105,'2026-05-19 00:32:38','::1','Ban to chuc #2 cong bo giai dau \"Giải TPHCM 2026\".'),(123,3,'Mo dang ky giai dau','Giaidau',105,'2026-05-19 00:32:38','::1','Ban to chuc #2 mo dang ky giai dau \"Giải TPHCM 2026\". Trang thai: CHUA_MO -> DANG_MO.'),(124,109,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-19 00:32:47','::1','Tai khoan #109 role HUAN_LUYEN_VIEN xem trang chu.'),(125,109,'Xem lich thi dau doi bong','Trandau',NULL,'2026-05-19 00:33:06','::1','HLV #10 xem lich thi dau doi #18 \"Đội super Men\". So tran: 0.'),(126,3,'Dong dang ky giai dau','Giaidau',105,'2026-05-19 00:33:40','::1','Ban to chuc #2 dong dang ky giai dau \"Giải TPHCM 2026\". Trang thai: DANG_MO -> DA_DONG.'),(127,109,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-19 13:09:43','::1','Tai khoan #109 role HUAN_LUYEN_VIEN xem trang chu.'),(128,3,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-19 13:09:51','::1','Tai khoan #3 role BAN_TO_CHUC xem trang chu.'),(129,109,'Cap nhat doi hinh','Doihinh',3,'2026-05-19 13:10:29','::1','HLV #10 cap nhat doi hinh #3 \"Đội hình chính (Nam)\".'),(130,109,'Cap nhat doi hinh','Doihinh',3,'2026-05-19 13:10:38','::1','HLV #10 cap nhat doi hinh #3 \"Đội hình chính (Nam)\".'),(131,109,'Cap nhat doi hinh','Doihinh',3,'2026-05-19 13:10:44','::1','HLV #10 cap nhat doi hinh #3 \"Đội hình chính (Nam)\".'),(132,110,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-19 13:12:24','::1','Tai khoan #110 role HUAN_LUYEN_VIEN xem trang chu.'),(133,110,'Tao doi bong','Doibong',19,'2026-05-19 13:14:20','::1','HLV #11 tao doi bong \"Đội bóng chính (Nam)\".'),(134,110,'Tao tai khoan van dong vien','Taikhoan',119,'2026-05-19 13:15:27','::1','HLV #11 tao truc tiep tai khoan VDV \"Thành viên 1\" cho doi #19 \"Đội bóng chính (Nam)\".'),(135,110,'Tao ho so van dong vien','Vandongvien',17,'2026-05-19 13:15:27','::1','HLV #11 tao truc tiep tai khoan VDV \"Thành viên 1\" cho doi #19 \"Đội bóng chính (Nam)\".'),(136,110,'Them van dong vien vao doi bong','Thanhviendoibong',15,'2026-05-19 13:15:27','::1','HLV #11 tao truc tiep tai khoan VDV \"Thành viên 1\" cho doi #19 \"Đội bóng chính (Nam)\".'),(137,110,'Tao tai khoan van dong vien','Taikhoan',120,'2026-05-19 13:16:30','::1','HLV #11 tao truc tiep tai khoan VDV \"Thành viên 2\" cho doi #19 \"Đội bóng chính (Nam)\".'),(138,110,'Tao ho so van dong vien','Vandongvien',18,'2026-05-19 13:16:30','::1','HLV #11 tao truc tiep tai khoan VDV \"Thành viên 2\" cho doi #19 \"Đội bóng chính (Nam)\".'),(139,110,'Them van dong vien vao doi bong','Thanhviendoibong',16,'2026-05-19 13:16:30','::1','HLV #11 tao truc tiep tai khoan VDV \"Thành viên 2\" cho doi #19 \"Đội bóng chính (Nam)\".'),(140,110,'Tao tai khoan van dong vien','Taikhoan',121,'2026-05-19 13:16:46','::1','HLV #11 tao truc tiep tai khoan VDV \"Thành viên 3\" cho doi #19 \"Đội bóng chính (Nam)\".'),(141,110,'Tao ho so van dong vien','Vandongvien',19,'2026-05-19 13:16:46','::1','HLV #11 tao truc tiep tai khoan VDV \"Thành viên 3\" cho doi #19 \"Đội bóng chính (Nam)\".'),(142,110,'Them van dong vien vao doi bong','Thanhviendoibong',17,'2026-05-19 13:16:46','::1','HLV #11 tao truc tiep tai khoan VDV \"Thành viên 3\" cho doi #19 \"Đội bóng chính (Nam)\".'),(143,110,'Tao tai khoan van dong vien','Taikhoan',122,'2026-05-19 13:16:59','::1','HLV #11 tao truc tiep tai khoan VDV \"Thành viên 4\" cho doi #19 \"Đội bóng chính (Nam)\".'),(144,110,'Tao ho so van dong vien','Vandongvien',20,'2026-05-19 13:16:59','::1','HLV #11 tao truc tiep tai khoan VDV \"Thành viên 4\" cho doi #19 \"Đội bóng chính (Nam)\".'),(145,110,'Them van dong vien vao doi bong','Thanhviendoibong',18,'2026-05-19 13:16:59','::1','HLV #11 tao truc tiep tai khoan VDV \"Thành viên 4\" cho doi #19 \"Đội bóng chính (Nam)\".'),(146,110,'Tao tai khoan van dong vien','Taikhoan',123,'2026-05-19 13:17:11','::1','HLV #11 tao truc tiep tai khoan VDV \"Thành viên 5\" cho doi #19 \"Đội bóng chính (Nam)\".'),(147,110,'Tao ho so van dong vien','Vandongvien',21,'2026-05-19 13:17:11','::1','HLV #11 tao truc tiep tai khoan VDV \"Thành viên 5\" cho doi #19 \"Đội bóng chính (Nam)\".'),(148,110,'Them van dong vien vao doi bong','Thanhviendoibong',19,'2026-05-19 13:17:11','::1','HLV #11 tao truc tiep tai khoan VDV \"Thành viên 5\" cho doi #19 \"Đội bóng chính (Nam)\".'),(149,110,'Tao tai khoan van dong vien','Taikhoan',124,'2026-05-19 13:17:23','::1','HLV #11 tao truc tiep tai khoan VDV \"Thành viên 6\" cho doi #19 \"Đội bóng chính (Nam)\".'),(150,110,'Tao ho so van dong vien','Vandongvien',22,'2026-05-19 13:17:23','::1','HLV #11 tao truc tiep tai khoan VDV \"Thành viên 6\" cho doi #19 \"Đội bóng chính (Nam)\".'),(151,110,'Them van dong vien vao doi bong','Thanhviendoibong',20,'2026-05-19 13:17:23','::1','HLV #11 tao truc tiep tai khoan VDV \"Thành viên 6\" cho doi #19 \"Đội bóng chính (Nam)\".'),(152,110,'Cap nhat doi bong','Doibong',19,'2026-05-19 13:18:41','::1','HLV #11 cap nhat doi bong #19 \"Đội bóng chính (Nam)\".'),(153,110,'Tao doi hinh','Doihinh',4,'2026-05-19 13:19:16','::1','HLV #11 tao doi hinh \"Đội hình chính (Nam)\" cho doi #19.'),(154,3,'Mo dang ky giai dau','Giaidau',105,'2026-05-19 13:19:26','::1','Ban to chuc #2 mo dang ky giai dau \"Giải TPHCM 2026\". Trang thai: DA_DONG -> DANG_MO.'),(155,110,'Xem lich thi dau doi bong','Trandau',NULL,'2026-05-19 13:37:43','::1','HLV #11 xem lich thi dau doi #19 \"Đội bóng Thủ đô\". So tran: 0.'),(156,3,'Dong dang ky giai dau','Giaidau',105,'2026-05-19 13:48:29','::1','Ban to chuc #2 dong dang ky giai dau \"Giải TPHCM 2026\". Trang thai: DANG_MO -> DA_DONG.'),(157,2,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-19 13:48:39','::1','Tai khoan #2 role BAN_TO_CHUC xem trang chu.'),(158,110,'Cap nhat doi hinh','Doihinh',4,'2026-05-19 17:47:23','::1','HLV #11 cap nhat doi hinh #4 \"Đội hình chính (Nam)\".'),(159,2,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-19 20:00:37','::1','Tai khoan #2 role BAN_TO_CHUC xem trang chu.'),(160,109,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-19 20:00:48','::1','Tai khoan #109 role HUAN_LUYEN_VIEN xem trang chu.'),(161,2,'Tao giai dau','Giaidau',106,'2026-05-19 20:03:39','::1','Ban to chuc #1 tao giai dau \"Giải quốc gia VN 2026\" theo cap #1, khu vuc #1.'),(162,2,'Cong bo giai dau','Giaidau',106,'2026-05-19 20:03:42','::1','Ban to chuc #1 cong bo giai dau \"Giải quốc gia VN 2026\".'),(163,2,'Mo dang ky giai dau','Giaidau',106,'2026-05-19 20:03:42','::1','Ban to chuc #1 mo dang ky giai dau \"Giải quốc gia VN 2026\". Trang thai: CHUA_MO -> DANG_MO.'),(164,109,'Cap nhat doi bong','Doibong',18,'2026-05-19 20:04:10','::1','HLV #10 cap nhat doi bong #18 \"Đội super Men\".'),(165,109,'Cap nhat doi hinh','Doihinh',3,'2026-05-19 20:04:29','::1','HLV #10 cap nhat doi hinh #3 \"Đội hình chính (Nam)\".'),(166,109,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-19 20:18:48','::1','Tai khoan #109 role HUAN_LUYEN_VIEN xem trang chu.'),(167,109,'Dang ky giai dau','Dangkygiaidau',11,'2026-05-19 21:07:44','::1','HLV #10 dang ky doi #18 \"Đội super Men\" tham gia giai dau #106 \"Giải quốc gia VN 2026\".'),(168,109,'Gui yeu cau xac nhan dang ky giai dau','Yeucauxacnhan',10,'2026-05-19 21:07:44','::1','HLV #10 dang ky doi #18 \"Đội super Men\" tham gia giai dau #106 \"Giải quốc gia VN 2026\".'),(169,110,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-19 21:07:51','::1','Tai khoan #110 role HUAN_LUYEN_VIEN xem trang chu.'),(170,110,'Cap nhat doi hinh','Doihinh',4,'2026-05-19 21:08:21','::1','HLV #11 cap nhat doi hinh #4 \"Đội hình chính\".'),(171,110,'Dang ky giai dau','Dangkygiaidau',12,'2026-05-19 21:08:29','::1','HLV #11 dang ky doi #19 \"Đội bóng Thủ đô\" tham gia giai dau #106 \"Giải quốc gia VN 2026\".'),(172,110,'Gui yeu cau xac nhan dang ky giai dau','Yeucauxacnhan',11,'2026-05-19 21:08:29','::1','HLV #11 dang ky doi #19 \"Đội bóng Thủ đô\" tham gia giai dau #106 \"Giải quốc gia VN 2026\".'),(173,2,'Duyet dang ky doi bong','Dangkygiaidau',12,'2026-05-19 21:08:36','::1','Ban to chuc #1 duyet dang ky cua doi \"Đội bóng Thủ đô\" vao giai dau \"Giải quốc gia VN 2026\".'),(174,2,'Duyet dang ky doi bong','Dangkygiaidau',11,'2026-05-19 21:08:37','::1','Ban to chuc #1 duyet dang ky cua doi \"Đội super Men\" vao giai dau \"Giải quốc gia VN 2026\".'),(175,110,'Xem lich thi dau doi bong','Trandau',NULL,'2026-05-19 21:08:59','::1','HLV #11 xem lich thi dau doi #19 \"Đội bóng Thủ đô\". So tran: 0.'),(176,2,'Dong dang ky giai dau','Giaidau',106,'2026-05-19 21:34:29','::1','Ban to chuc #1 dong dang ky giai dau \"Giải quốc gia VN 2026\". Trang thai: DANG_MO -> DA_DONG.'),(177,2,'Cap nhat giai dau','Giaidau',106,'2026-05-19 21:34:36','::1','Ban to chuc #1 cap nhat giai dau \"Giải quốc gia VN 2026\". Truong thay doi: tengiaidau, mota, idcapgiaidau, idkhuvucphamvi, idluat, thoigianbatdau, thoigianketthuc, quymo, hinhanh, tinhchat, gioitinh, ghichu_diadiem, dieule, thethuc, quytac, dieukien.'),(178,2,'Them tran dau','Trandau',17,'2026-05-19 22:46:39','::1','Ban to chuc #1 them tran dau giai \"Giải quốc gia VN 2026\": slot 1 doi #19, slot 2 doi #18, san #4, bat dau 2026-06-02 09:00:00.'),(179,6,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-19 22:47:16','::1','Tai khoan #6 role TRONG_TAI xem trang chu.'),(180,6,'Xem danh sach giai dau duoc phan cong','Trongtai',1,'2026-05-19 22:47:21','::1','Trong tai #1 xem danh sach giai dau co phan cong. So dong: 1'),(181,6,'Xem danh sach san dau duoc phan cong','Trongtai',1,'2026-05-19 22:47:21','::1','Trong tai #1 xem danh sach san dau co phan cong. So dong: 1'),(182,6,'Xem lich phan cong trong tai','Trongtai',1,'2026-05-19 22:47:21','::1','Trong tai #1 xem lich phan cong tran dau. So dong: 1'),(183,6,'Xem danh sach giai dau duoc phan cong','Trongtai',1,'2026-05-19 22:47:33','::1','Trong tai #1 xem danh sach giai dau co phan cong. So dong: 1'),(184,6,'Xem danh sach san dau duoc phan cong','Trongtai',1,'2026-05-19 22:47:33','::1','Trong tai #1 xem danh sach san dau co phan cong. So dong: 1'),(185,6,'Xem lich phan cong trong tai','Trongtai',1,'2026-05-19 22:47:33','::1','Trong tai #1 xem lich phan cong tran dau. So dong: 1'),(186,6,'Xem thong tin chi tiet tran dau','Trandau',17,'2026-05-19 22:47:35','::1','Trong tai #1 xem thong tin chi tiet tran #17 (Đội bóng Thủ đô vs Đội super Men), giai #106.'),(187,6,'Xem danh sach don nghi phep trong tai','Trongtai',1,'2026-05-19 22:47:41','::1','Trong tai #1 xem danh sach don nghi phep. So dong: 0'),(188,6,'Xem danh sach tran dau co the bao cao su co','Trongtai',1,'2026-05-19 22:47:41','::1','Trong tai #1 xem danh sach tran dau co the bao cao su co. So dong: 1'),(189,6,'Xem danh sach bao cao su co','Trongtai',1,'2026-05-19 22:47:41','::1','Trong tai #1 xem danh sach bao cao su co. So dong: 0'),(190,6,'Xem danh sach don nghi phep trong tai','Trongtai',1,'2026-05-19 22:47:41','::1','Trong tai #1 xem danh sach don nghi phep. So dong: 0'),(191,6,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-20 11:09:30','::1','Tai khoan #6 role TRONG_TAI xem trang chu.'),(192,6,'Xem danh sach giai dau duoc phan cong','Trongtai',1,'2026-05-20 11:18:52','::1','Trong tai #1 xem danh sach giai dau co phan cong. So dong: 1'),(193,6,'Xem danh sach san dau duoc phan cong','Trongtai',1,'2026-05-20 11:18:52','::1','Trong tai #1 xem danh sach san dau co phan cong. So dong: 1'),(194,6,'Xem lich phan cong trong tai','Trongtai',1,'2026-05-20 11:18:52','::1','Trong tai #1 xem lich phan cong tran dau. So dong: 1'),(195,6,'Xem danh sach giai dau duoc phan cong','Trongtai',1,'2026-05-20 11:19:00','::1','Trong tai #1 xem danh sach giai dau co phan cong. So dong: 1'),(196,6,'Xem danh sach san dau duoc phan cong','Trongtai',1,'2026-05-20 11:19:00','::1','Trong tai #1 xem danh sach san dau co phan cong. So dong: 1'),(197,6,'Xem lich phan cong trong tai','Trongtai',1,'2026-05-20 11:19:00','::1','Trong tai #1 xem lich phan cong tran dau. So dong: 1'),(198,6,'Xem danh sach giai dau duoc phan cong','Trongtai',1,'2026-05-20 12:56:19','::1','Trong tai #1 xem danh sach giai dau co phan cong. So dong: 1'),(199,6,'Xem danh sach san dau duoc phan cong','Trongtai',1,'2026-05-20 12:56:19','::1','Trong tai #1 xem danh sach san dau co phan cong. So dong: 1'),(200,6,'Xem lich phan cong trong tai','Trongtai',1,'2026-05-20 12:56:19','::1','Trong tai #1 xem lich phan cong tran dau. So dong: 1'),(201,6,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-20 13:46:01','::1','Tai khoan #6 role TRONG_TAI xem trang chu.'),(202,6,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-20 13:46:25','::1','Tai khoan #6 role TRONG_TAI xem trang chu.'),(203,6,'Xem danh sach don nghi phep trong tai','Trongtai',1,'2026-05-20 13:46:30','::1','Trong tai #1 xem danh sach don nghi phep. So dong: 0'),(204,6,'Xem danh sach giai dau duoc phan cong','Trongtai',1,'2026-05-20 13:46:30','::1','Trong tai #1 xem danh sach giai dau co phan cong. So dong: 1'),(205,6,'Xem danh sach san dau duoc phan cong','Trongtai',1,'2026-05-20 13:46:30','::1','Trong tai #1 xem danh sach san dau co phan cong. So dong: 1'),(206,6,'Xem lich phan cong trong tai','Trongtai',1,'2026-05-20 13:46:30','::1','Trong tai #1 xem lich phan cong tran dau. So dong: 1'),(207,6,'Xem danh sach giai dau duoc phan cong','Trongtai',1,'2026-05-20 13:48:31','::1','Trong tai #1 xem danh sach giai dau co phan cong. So dong: 1'),(208,6,'Xem danh sach san dau duoc phan cong','Trongtai',1,'2026-05-20 13:48:31','::1','Trong tai #1 xem danh sach san dau co phan cong. So dong: 1'),(209,6,'Xem lich phan cong trong tai','Trongtai',1,'2026-05-20 13:48:31','::1','Trong tai #1 xem lich phan cong tran dau. So dong: 1'),(210,6,'Xem danh sach giai dau duoc phan cong','Trongtai',1,'2026-05-20 17:56:47','::1','Trong tai #1 xem danh sach giai dau co phan cong. So dong: 1'),(211,6,'Xem danh sach san dau duoc phan cong','Trongtai',1,'2026-05-20 17:56:47','::1','Trong tai #1 xem danh sach san dau co phan cong. So dong: 1'),(212,6,'Xem lich phan cong trong tai','Trongtai',1,'2026-05-20 17:56:47','::1','Trong tai #1 xem lich phan cong tran dau. So dong: 1'),(213,6,'Xem danh sach giai dau duoc phan cong','Trongtai',1,'2026-05-20 19:19:29','::1','Trong tai #1 xem danh sach giai dau co phan cong. So dong: 1'),(214,6,'Xem danh sach san dau duoc phan cong','Trongtai',1,'2026-05-20 19:19:29','::1','Trong tai #1 xem danh sach san dau co phan cong. So dong: 1'),(215,6,'Xem lich phan cong trong tai','Trongtai',1,'2026-05-20 19:19:29','::1','Trong tai #1 xem lich phan cong tran dau. So dong: 1'),(216,6,'Xem danh sach giai dau duoc phan cong','Trongtai',1,'2026-05-20 19:20:04','::1','Trong tai #1 xem danh sach giai dau co phan cong. So dong: 1'),(217,6,'Xem danh sach san dau duoc phan cong','Trongtai',1,'2026-05-20 19:20:04','::1','Trong tai #1 xem danh sach san dau co phan cong. So dong: 1'),(218,6,'Xem lich phan cong trong tai','Trongtai',1,'2026-05-20 19:20:04','::1','Trong tai #1 xem lich phan cong tran dau. So dong: 1'),(219,6,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-20 19:20:36','::1','Tai khoan #6 role TRONG_TAI xem trang chu.'),(220,6,'Xem danh sach giai dau duoc phan cong','Trongtai',1,'2026-05-20 19:20:53','::1','Trong tai #1 xem danh sach giai dau co phan cong. So dong: 1'),(221,6,'Xem danh sach san dau duoc phan cong','Trongtai',1,'2026-05-20 19:20:53','::1','Trong tai #1 xem danh sach san dau co phan cong. So dong: 1'),(222,6,'Xem lich phan cong trong tai','Trongtai',1,'2026-05-20 19:20:53','::1','Trong tai #1 xem lich phan cong tran dau. So dong: 1'),(223,6,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-20 19:21:19','::1','Tai khoan #6 role TRONG_TAI xem trang chu.'),(224,6,'Xem danh sach giai dau duoc phan cong','Trongtai',1,'2026-05-20 19:21:20','::1','Trong tai #1 xem danh sach giai dau co phan cong. So dong: 1'),(225,6,'Xem danh sach san dau duoc phan cong','Trongtai',1,'2026-05-20 19:21:20','::1','Trong tai #1 xem danh sach san dau co phan cong. So dong: 1'),(226,6,'Xem lich phan cong trong tai','Trongtai',1,'2026-05-20 19:21:20','::1','Trong tai #1 xem lich phan cong tran dau. So dong: 1'),(227,6,'Xem danh sach giai dau duoc phan cong','Trongtai',1,'2026-05-20 19:42:09','::1','Trong tai #1 xem danh sach giai dau co phan cong. So dong: 1'),(228,6,'Xem danh sach san dau duoc phan cong','Trongtai',1,'2026-05-20 19:42:09','::1','Trong tai #1 xem danh sach san dau co phan cong. So dong: 1'),(229,6,'Xem lich phan cong trong tai','Trongtai',1,'2026-05-20 19:42:09','::1','Trong tai #1 xem lich phan cong tran dau. So dong: 1'),(230,6,'Xem chi tiet phan cong trong tai','Phancongtrongtai',7,'2026-05-20 19:42:12','::1','Trong tai #1 xem phan cong #7, tran #17 (Đội bóng Thủ đô vs Đội super Men), vai tro TRONG_TAI_CHINH.'),(231,6,'Xem giao dien giam sat tran dau','Trandau',17,'2026-05-20 19:42:35','::1','Trong tai #1 xem giao dien giam sat tran #17 (Đội bóng Thủ đô vs Đội super Men), giai #106.'),(232,7,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-20 19:44:15','::1','Tai khoan #7 role TRONG_TAI xem trang chu.'),(233,7,'Xem danh sach giai dau duoc phan cong','Trongtai',2,'2026-05-20 19:44:19','::1','Trong tai #2 xem danh sach giai dau co phan cong. So dong: 1'),(234,7,'Xem danh sach san dau duoc phan cong','Trongtai',2,'2026-05-20 19:44:19','::1','Trong tai #2 xem danh sach san dau co phan cong. So dong: 1'),(235,7,'Xem lich phan cong trong tai','Trongtai',2,'2026-05-20 19:44:19','::1','Trong tai #2 xem lich phan cong tran dau. So dong: 1'),(236,7,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-20 19:44:30','::1','Tai khoan #7 role TRONG_TAI xem trang chu.'),(237,7,'Xem danh sach giai dau duoc phan cong','Trongtai',2,'2026-05-20 19:44:34','::1','Trong tai #2 xem danh sach giai dau co phan cong. So dong: 1'),(238,7,'Xem danh sach san dau duoc phan cong','Trongtai',2,'2026-05-20 19:44:34','::1','Trong tai #2 xem danh sach san dau co phan cong. So dong: 1'),(239,7,'Xem lich phan cong trong tai','Trongtai',2,'2026-05-20 19:44:34','::1','Trong tai #2 xem lich phan cong tran dau. So dong: 1'),(240,6,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-20 19:44:41','::1','Tai khoan #6 role TRONG_TAI xem trang chu.'),(241,6,'Xem danh sach giai dau duoc phan cong','Trongtai',1,'2026-05-20 19:44:44','::1','Trong tai #1 xem danh sach giai dau co phan cong. So dong: 1'),(242,6,'Xem danh sach san dau duoc phan cong','Trongtai',1,'2026-05-20 19:44:44','::1','Trong tai #1 xem danh sach san dau co phan cong. So dong: 1'),(243,6,'Xem lich phan cong trong tai','Trongtai',1,'2026-05-20 19:44:44','::1','Trong tai #1 xem lich phan cong tran dau. So dong: 1'),(244,6,'Xem chi tiet phan cong trong tai','Phancongtrongtai',7,'2026-05-20 19:46:11','::1','Trong tai #1 xem phan cong #7, tran #17 (Đội bóng Thủ đô vs Đội super Men), vai tro TRONG_TAI_CHINH.'),(245,6,'Xem thong tin chi tiet tran dau','Trandau',17,'2026-05-20 19:46:17','::1','Trong tai #1 xem thong tin chi tiet tran #17 (Đội bóng Thủ đô vs Đội super Men), giai #106.'),(246,6,'Xem giao dien giam sat tran dau','Trandau',17,'2026-05-20 19:46:22','::1','Trong tai #1 xem giao dien giam sat tran #17 (Đội bóng Thủ đô vs Đội super Men), giai #106.'),(247,6,'Xem danh sach giai dau duoc phan cong','Trongtai',1,'2026-05-20 19:46:27','::1','Trong tai #1 xem danh sach giai dau co phan cong. So dong: 1'),(248,6,'Xem danh sach san dau duoc phan cong','Trongtai',1,'2026-05-20 19:46:27','::1','Trong tai #1 xem danh sach san dau co phan cong. So dong: 1'),(249,6,'Xem lich phan cong trong tai','Trongtai',1,'2026-05-20 19:46:27','::1','Trong tai #1 xem lich phan cong tran dau. So dong: 1'),(250,6,'Xem giao dien giam sat tran dau','Trandau',17,'2026-05-20 19:46:32','::1','Trong tai #1 xem giao dien giam sat tran #17 (Đội bóng Thủ đô vs Đội super Men), giai #106.'),(251,6,'Xac nhan tham gia tran dau','Phancongtrongtai',7,'2026-05-20 19:46:32','::1','Trong tai #1 xac nhan tham gia tran dau phan cong #7, tran #17 (Đội bóng Thủ đô vs Đội super Men), vai tro TRONG_TAI_CHINH.'),(252,6,'Xem danh sach giai dau duoc phan cong','Trongtai',1,'2026-05-20 19:46:35','::1','Trong tai #1 xem danh sach giai dau co phan cong. So dong: 1'),(253,6,'Xem danh sach san dau duoc phan cong','Trongtai',1,'2026-05-20 19:46:35','::1','Trong tai #1 xem danh sach san dau co phan cong. So dong: 1'),(254,6,'Xem lich phan cong trong tai','Trongtai',1,'2026-05-20 19:46:35','::1','Trong tai #1 xem lich phan cong tran dau. So dong: 1'),(255,7,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-20 19:46:41','::1','Tai khoan #7 role TRONG_TAI xem trang chu.'),(256,7,'Xem danh sach giai dau duoc phan cong','Trongtai',2,'2026-05-20 19:46:44','::1','Trong tai #2 xem danh sach giai dau co phan cong. So dong: 1'),(257,7,'Xem danh sach san dau duoc phan cong','Trongtai',2,'2026-05-20 19:46:44','::1','Trong tai #2 xem danh sach san dau co phan cong. So dong: 1'),(258,7,'Xem lich phan cong trong tai','Trongtai',2,'2026-05-20 19:46:44','::1','Trong tai #2 xem lich phan cong tran dau. So dong: 1'),(259,7,'Xem giao dien giam sat tran dau','Trandau',17,'2026-05-20 19:46:46','::1','Trong tai #2 xem giao dien giam sat tran #17 (Đội bóng Thủ đô vs Đội super Men), giai #106.'),(260,7,'Xac nhan tham gia tran dau','Phancongtrongtai',8,'2026-05-20 19:46:47','::1','Trong tai #2 xac nhan tham gia tran dau phan cong #8, tran #17 (Đội bóng Thủ đô vs Đội super Men), vai tro GIAM_SAT.'),(261,7,'Xem danh sach giai dau duoc phan cong','Trongtai',2,'2026-05-20 19:46:49','::1','Trong tai #2 xem danh sach giai dau co phan cong. So dong: 1'),(262,7,'Xem danh sach san dau duoc phan cong','Trongtai',2,'2026-05-20 19:46:49','::1','Trong tai #2 xem danh sach san dau co phan cong. So dong: 1'),(263,7,'Xem lich phan cong trong tai','Trongtai',2,'2026-05-20 19:46:49','::1','Trong tai #2 xem lich phan cong tran dau. So dong: 1'),(264,7,'Xem giao dien giam sat tran dau','Trandau',17,'2026-05-20 19:46:52','::1','Trong tai #2 xem giao dien giam sat tran #17 (Đội bóng Thủ đô vs Đội super Men), giai #106.'),(265,7,'Xem danh sach giai dau duoc phan cong','Trongtai',2,'2026-05-20 19:47:01','::1','Trong tai #2 xem danh sach giai dau co phan cong. So dong: 1'),(266,7,'Xem danh sach san dau duoc phan cong','Trongtai',2,'2026-05-20 19:47:01','::1','Trong tai #2 xem danh sach san dau co phan cong. So dong: 1'),(267,7,'Xem lich phan cong trong tai','Trongtai',2,'2026-05-20 19:47:01','::1','Trong tai #2 xem lich phan cong tran dau. So dong: 1'),(268,7,'Xem giao dien giam sat tran dau','Trandau',17,'2026-05-20 19:47:08','::1','Trong tai #2 xem giao dien giam sat tran #17 (Đội bóng Thủ đô vs Đội super Men), giai #106.'),(269,7,'Xem danh sach giai dau duoc phan cong','Trongtai',2,'2026-05-20 19:47:10','::1','Trong tai #2 xem danh sach giai dau co phan cong. So dong: 1'),(270,7,'Xem danh sach san dau duoc phan cong','Trongtai',2,'2026-05-20 19:47:10','::1','Trong tai #2 xem danh sach san dau co phan cong. So dong: 1'),(271,7,'Xem lich phan cong trong tai','Trongtai',2,'2026-05-20 19:47:10','::1','Trong tai #2 xem lich phan cong tran dau. So dong: 1'),(272,7,'Xem chi tiet phan cong trong tai','Phancongtrongtai',8,'2026-05-20 19:47:21','::1','Trong tai #2 xem phan cong #8, tran #17 (Đội bóng Thủ đô vs Đội super Men), vai tro GIAM_SAT.'),(273,7,'Xem giao dien giam sat tran dau','Trandau',17,'2026-05-20 19:47:28','::1','Trong tai #2 xem giao dien giam sat tran #17 (Đội bóng Thủ đô vs Đội super Men), giai #106.'),(274,7,'Xem danh sach giai dau duoc phan cong','Trongtai',2,'2026-05-20 19:47:30','::1','Trong tai #2 xem danh sach giai dau co phan cong. So dong: 1'),(275,7,'Xem danh sach san dau duoc phan cong','Trongtai',2,'2026-05-20 19:47:30','::1','Trong tai #2 xem danh sach san dau co phan cong. So dong: 1'),(276,7,'Xem lich phan cong trong tai','Trongtai',2,'2026-05-20 19:47:30','::1','Trong tai #2 xem lich phan cong tran dau. So dong: 1'),(277,7,'Xem giao dien giam sat tran dau','Trandau',17,'2026-05-20 19:47:41','::1','Trong tai #2 xem giao dien giam sat tran #17 (Đội bóng Thủ đô vs Đội super Men), giai #106.'),(278,7,'Xem danh sach giai dau duoc phan cong','Trongtai',2,'2026-05-20 19:49:05','::1','Trong tai #2 xem danh sach giai dau co phan cong. So dong: 1'),(279,7,'Xem danh sach san dau duoc phan cong','Trongtai',2,'2026-05-20 19:49:05','::1','Trong tai #2 xem danh sach san dau co phan cong. So dong: 1'),(280,7,'Xem lich phan cong trong tai','Trongtai',2,'2026-05-20 19:49:05','::1','Trong tai #2 xem lich phan cong tran dau. So dong: 1'),(281,7,'Xem chi tiet phan cong trong tai','Phancongtrongtai',8,'2026-05-20 19:49:06','::1','Trong tai #2 xem phan cong #8, tran #17 (Đội bóng Thủ đô vs Đội super Men), vai tro GIAM_SAT.'),(282,7,'Xem chi tiet phan cong trong tai','Phancongtrongtai',8,'2026-05-20 19:49:10','::1','Trong tai #2 xem phan cong #8, tran #17 (Đội bóng Thủ đô vs Đội super Men), vai tro GIAM_SAT.'),(283,6,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-20 21:13:50','::1','Tai khoan #6 role TRONG_TAI xem trang chu.'),(284,6,'Xem danh sach giai dau duoc phan cong','Trongtai',1,'2026-05-20 21:13:52','::1','Trong tai #1 xem danh sach giai dau co phan cong. So dong: 1'),(285,6,'Xem danh sach san dau duoc phan cong','Trongtai',1,'2026-05-20 21:13:52','::1','Trong tai #1 xem danh sach san dau co phan cong. So dong: 1'),(286,6,'Xem lich phan cong trong tai','Trongtai',1,'2026-05-20 21:13:52','::1','Trong tai #1 xem lich phan cong tran dau. So dong: 1');
/*!40000 ALTER TABLE `nhatkyhethong` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `nhatkytrangthai`
--

DROP TABLE IF EXISTS `nhatkytrangthai`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nhatkytrangthai` (
  `idnhatkytrangthai` int(11) NOT NULL AUTO_INCREMENT,
  `loaidoituong` varchar(100) NOT NULL,
  `iddoituong` int(11) NOT NULL,
  `trangthaicu` varchar(100) DEFAULT NULL,
  `trangthaimoi` varchar(100) NOT NULL,
  `lydo` varchar(1000) DEFAULT NULL,
  `idnguoithuchien` int(11) DEFAULT NULL,
  `thoigian` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`idnhatkytrangthai`),
  KEY `fk_nktt_taikhoan` (`idnguoithuchien`),
  CONSTRAINT `fk_nktt_taikhoan` FOREIGN KEY (`idnguoithuchien`) REFERENCES `taikhoan` (`idtaikhoan`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_nktt_loaidoituong` CHECK (`loaidoituong` in ('TAI_KHOAN','GIAI_DAU','DOI_BONG','SAN_DAU','TRAN_DAU','DANG_KY_GIAI','KHIEU_NAI','YEU_CAU_XAC_NHAN','VONG_DAU'))
) ENGINE=InnoDB AUTO_INCREMENT=68 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nhatkytrangthai`
--

LOCK TABLES `nhatkytrangthai` WRITE;
/*!40000 ALTER TABLE `nhatkytrangthai` DISABLE KEYS */;
INSERT INTO `nhatkytrangthai` VALUES (10,'TAI_KHOAN',104,NULL,'CHO_DUYET','Dang ky tai khoan huan luyen vien',NULL,'2026-05-18 11:44:19'),(11,'YEU_CAU_XAC_NHAN',2,NULL,'CHO_DUYET','Gui yeu cau xac nhan tu cach HLV',NULL,'2026-05-18 11:44:19'),(20,'TAI_KHOAN',109,NULL,'CHO_DUYET','Dang ky tai khoan huan luyen vien',109,'2026-05-18 13:23:36'),(21,'YEU_CAU_XAC_NHAN',7,NULL,'CHO_DUYET','Gui yeu cau xac nhan tu cach HLV',109,'2026-05-18 13:23:36'),(22,'TAI_KHOAN',109,'CHO_DUYET','HOAT_DONG','Xac nhan tu cach huan luyen vien',3,'2026-05-18 13:24:39'),(23,'YEU_CAU_XAC_NHAN',7,'CHO_DUYET','DA_DUYET','Xac nhan tu cach huan luyen vien',3,'2026-05-18 13:24:39'),(24,'TAI_KHOAN',110,NULL,'CHO_DUYET','Dang ky tai khoan huan luyen vien',110,'2026-05-18 13:26:33'),(25,'YEU_CAU_XAC_NHAN',8,NULL,'CHO_DUYET','Gui yeu cau xac nhan tu cach HLV',110,'2026-05-18 13:26:33'),(26,'TAI_KHOAN',110,'CHO_DUYET','HOAT_DONG','Xac nhan tu cach huan luyen vien',3,'2026-05-18 13:26:54'),(27,'YEU_CAU_XAC_NHAN',8,'CHO_DUYET','DA_DUYET','Xac nhan tu cach huan luyen vien',3,'2026-05-18 13:26:54'),(31,'TAI_KHOAN',113,NULL,'HOAT_DONG','HLV tao tai khoan van dong vien',109,'2026-05-18 14:09:45'),(32,'TAI_KHOAN',114,NULL,'HOAT_DONG','HLV tao tai khoan van dong vien',109,'2026-05-18 14:10:31'),(33,'TAI_KHOAN',115,NULL,'HOAT_DONG','HLV tao tai khoan van dong vien',109,'2026-05-18 14:10:52'),(34,'TAI_KHOAN',116,NULL,'HOAT_DONG','HLV tao tai khoan van dong vien',109,'2026-05-18 14:11:07'),(35,'TAI_KHOAN',117,NULL,'HOAT_DONG','HLV tao tai khoan van dong vien',109,'2026-05-18 14:11:21'),(36,'TAI_KHOAN',118,NULL,'HOAT_DONG','HLV tao tai khoan van dong vien',109,'2026-05-18 14:11:36'),(39,'DOI_BONG',18,NULL,'HOAT_DONG','HLV tao doi bong',109,'2026-05-18 15:10:51'),(40,'GIAI_DAU',105,NULL,'NHAP','Tao giai dau o trang thai nhap',3,'2026-05-19 00:32:32'),(41,'GIAI_DAU',105,NULL,'DA_CONG_BO','Cong bo giai dau',3,'2026-05-19 00:32:38'),(42,'GIAI_DAU',105,'CHUA_MO','DANG_MO','Mo dang ky giai dau',3,'2026-05-19 00:32:38'),(43,'GIAI_DAU',105,'DANG_MO','DA_DONG','Dong dang ky giai dau',3,'2026-05-19 00:33:40'),(44,'DOI_BONG',19,NULL,'HOAT_DONG','HLV tao doi bong',110,'2026-05-19 13:14:20'),(45,'TAI_KHOAN',119,NULL,'HOAT_DONG','HLV tao tai khoan van dong vien',110,'2026-05-19 13:15:27'),(46,'TAI_KHOAN',120,NULL,'HOAT_DONG','HLV tao tai khoan van dong vien',110,'2026-05-19 13:16:30'),(47,'TAI_KHOAN',121,NULL,'HOAT_DONG','HLV tao tai khoan van dong vien',110,'2026-05-19 13:16:46'),(48,'TAI_KHOAN',122,NULL,'HOAT_DONG','HLV tao tai khoan van dong vien',110,'2026-05-19 13:16:59'),(49,'TAI_KHOAN',123,NULL,'HOAT_DONG','HLV tao tai khoan van dong vien',110,'2026-05-19 13:17:11'),(50,'TAI_KHOAN',124,NULL,'HOAT_DONG','HLV tao tai khoan van dong vien',110,'2026-05-19 13:17:23'),(51,'GIAI_DAU',105,'DA_DONG','DANG_MO','Mo dang ky giai dau',3,'2026-05-19 13:19:26'),(52,'GIAI_DAU',105,'DANG_MO','DA_DONG','Dong dang ky giai dau',3,'2026-05-19 13:48:29'),(53,'GIAI_DAU',106,NULL,'NHAP','Tao giai dau o trang thai nhap',2,'2026-05-19 20:03:39'),(54,'GIAI_DAU',106,NULL,'DA_CONG_BO','Cong bo giai dau',2,'2026-05-19 20:03:42'),(55,'GIAI_DAU',106,'CHUA_MO','DANG_MO','Mo dang ky giai dau',2,'2026-05-19 20:03:42'),(56,'DANG_KY_GIAI',11,NULL,'CHO_DUYET','HLV dang ky giai dau',109,'2026-05-19 21:07:44'),(57,'YEU_CAU_XAC_NHAN',10,NULL,'CHO_DUYET','Gui yeu cau xac nhan dang ky giai dau',109,'2026-05-19 21:07:44'),(58,'DANG_KY_GIAI',12,NULL,'CHO_DUYET','HLV dang ky giai dau',110,'2026-05-19 21:08:29'),(59,'YEU_CAU_XAC_NHAN',11,NULL,'CHO_DUYET','Gui yeu cau xac nhan dang ky giai dau',110,'2026-05-19 21:08:29'),(60,'DANG_KY_GIAI',12,'CHO_DUYET','DA_DUYET','Duyet dang ky doi bong',2,'2026-05-19 21:08:36'),(61,'YEU_CAU_XAC_NHAN',11,'CHO_DUYET','DA_DUYET','Duyet dang ky doi bong',2,'2026-05-19 21:08:36'),(62,'DANG_KY_GIAI',11,'CHO_DUYET','DA_DUYET','Duyet dang ky doi bong',2,'2026-05-19 21:08:37'),(63,'YEU_CAU_XAC_NHAN',10,'CHO_DUYET','DA_DUYET','Duyet dang ky doi bong',2,'2026-05-19 21:08:37'),(64,'GIAI_DAU',106,'DANG_MO','DA_DONG','Dong dang ky giai dau',2,'2026-05-19 21:34:29'),(65,'TRAN_DAU',17,NULL,'DA_XEP_LICH','Them tran dau',2,'2026-05-19 22:46:39'),(66,'TRAN_DAU',17,'CHO_XAC_NHAN','DA_XAC_NHAN','Trong tai xac nhan tham gia tran dau',6,'2026-05-20 19:46:32'),(67,'TRAN_DAU',17,'CHO_XAC_NHAN','DA_XAC_NHAN','Trong tai xac nhan tham gia tran dau',7,'2026-05-20 19:46:47');
/*!40000 ALTER TABLE `nhatkytrangthai` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `phancongtrongtai`
--

DROP TABLE IF EXISTS `phancongtrongtai`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `phancongtrongtai` (
  `idphancong` int(11) NOT NULL AUTO_INCREMENT,
  `idtrandau` int(11) NOT NULL,
  `idtrongtai` int(11) NOT NULL,
  `vaitro` varchar(100) NOT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'CHO_XAC_NHAN',
  `ngayphancong` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`idphancong`),
  UNIQUE KEY `uq_pctt` (`idtrandau`,`idtrongtai`),
  KEY `fk_pctt_trongtai` (`idtrongtai`),
  CONSTRAINT `fk_pctt_tran` FOREIGN KEY (`idtrandau`) REFERENCES `trandau` (`idtrandau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_pctt_trongtai` FOREIGN KEY (`idtrongtai`) REFERENCES `trongtai` (`idtrongtai`) ON UPDATE CASCADE,
  CONSTRAINT `chk_pctt_vaitro` CHECK (`vaitro` in ('TRONG_TAI_CHINH','TRONG_TAI_PHU','GIAM_SAT')),
  CONSTRAINT `chk_pctt_trangthai` CHECK (`trangthai` in ('CHO_XAC_NHAN','DA_XAC_NHAN','TU_CHOI','DA_HUY'))
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `phancongtrongtai`
--

LOCK TABLES `phancongtrongtai` WRITE;
/*!40000 ALTER TABLE `phancongtrongtai` DISABLE KEYS */;
INSERT INTO `phancongtrongtai` VALUES (7,17,1,'TRONG_TAI_CHINH','DA_XAC_NHAN','2026-05-19 22:46:39'),(8,17,2,'GIAM_SAT','DA_XAC_NHAN','2026-05-19 22:46:39');
/*!40000 ALTER TABLE `phancongtrongtai` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_phancong_bi
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `phiendangnhap`
--

DROP TABLE IF EXISTS `phiendangnhap`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `phiendangnhap` (
  `idphien` int(11) NOT NULL AUTO_INCREMENT,
  `idtaikhoan` int(11) NOT NULL,
  `token` varchar(500) NOT NULL,
  `thoigiandangnhap` datetime NOT NULL DEFAULT current_timestamp(),
  `thoigiandangxuat` datetime DEFAULT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'DANG_HOAT_DONG',
  PRIMARY KEY (`idphien`),
  UNIQUE KEY `token` (`token`),
  KEY `fk_phien_taikhoan` (`idtaikhoan`),
  CONSTRAINT `fk_phien_taikhoan` FOREIGN KEY (`idtaikhoan`) REFERENCES `taikhoan` (`idtaikhoan`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_phien_trangthai` CHECK (`trangthai` in ('DANG_HOAT_DONG','DA_DANG_XUAT','HET_HAN')),
  CONSTRAINT `chk_phien_thoigian` CHECK (`thoigiandangxuat` is null or `thoigiandangxuat` >= `thoigiandangnhap`)
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `phiendangnhap`
--

LOCK TABLES `phiendangnhap` WRITE;
/*!40000 ALTER TABLE `phiendangnhap` DISABLE KEYS */;
INSERT INTO `phiendangnhap` VALUES (19,3,'8ddc4ca6e4f15ebaa590b840a08cdcfd825209716967674eb32cf2e9d245b495','2026-05-18 13:24:22','2026-05-18 13:26:59','DA_DANG_XUAT'),(20,109,'10f0f967198aff35187fd908b9751ba9e0915b7c3315a745051dca7f67deb198','2026-05-18 13:27:14','2026-05-18 13:29:50','DA_DANG_XUAT'),(21,109,'ef4d3353d863286daefec780b09b7a9eb53d9f2d8b57f5123138cacca3157bd4','2026-05-18 13:29:54','2026-05-18 13:29:58','DA_DANG_XUAT'),(22,3,'44e0839f2c2e7c1035dc4bcf552c00567dae6235126326d797b60c918eb38691','2026-05-18 13:30:09','2026-05-18 13:47:42','DA_DANG_XUAT'),(23,109,'0ca7c4de8005bbeb24fe1db810a0695d6e4ecbf4b1644a52e3d2974abc77f064','2026-05-18 13:47:47','2026-05-18 21:39:39','DA_DANG_XUAT'),(24,113,'d98175516d60f2ec12ac48a009ae4e2f4f0c1c4469e80c551b0f8a59f2fa0476','2026-05-18 14:20:17',NULL,'DANG_HOAT_DONG'),(25,113,'e39ed8b255bac42c43a947198c4b44a0ae0875d8956418fb9a4490f7cee3070b','2026-05-18 21:10:59','2026-05-18 21:11:32','DA_DANG_XUAT'),(26,114,'faff1ea3531d31816a669f593eb9b768e6932245a3a5bc6965d865b058e62821','2026-05-18 21:11:37','2026-05-18 21:11:55','DA_DANG_XUAT'),(27,115,'17a133541e0b0496ff4c3ce14b3e0912cd4e566a7bbabb25b3ee6a2717913900','2026-05-18 21:11:59','2026-05-18 21:12:18','DA_DANG_XUAT'),(28,115,'57001a58de86369c19b0fd65cb8578a780c982b2441180d5ba263ddc3bf25b3d','2026-05-18 21:12:23','2026-05-18 21:12:36','DA_DANG_XUAT'),(29,116,'4b5c49932431c6af4d69cf75a0f06d3043ac052f4da0583d9f2766f16734c74d','2026-05-18 21:12:40','2026-05-18 21:12:55','DA_DANG_XUAT'),(30,117,'9d32e0c6d7b55044b02a43da5b20de72143371c915d96c80f58c43384ac4043d','2026-05-18 21:12:59','2026-05-18 21:13:13','DA_DANG_XUAT'),(31,118,'28a6ae00a2ff5c15dc9fb5d6f5ba2434f1142278ab0d50ee8207c5293cd22e04','2026-05-18 21:13:19','2026-05-19 00:29:51','DA_DANG_XUAT'),(32,109,'052cc39fda73a4412878b63b5f98c89a59e741f21654ac2d0a40edab5bba3c2d','2026-05-18 21:50:15','2026-05-19 00:29:30','DA_DANG_XUAT'),(33,3,'9ebde635c49214c0c3e51983dccc5ee0907a5db1284114679b61a7c237dd0377','2026-05-19 00:30:14',NULL,'DANG_HOAT_DONG'),(34,109,'b29e578d671afc964ee542aaec0ed01f557c0a04d928aa3a2b78dd60ba5fc7e9','2026-05-19 00:32:47',NULL,'DANG_HOAT_DONG'),(35,109,'19e8434aeefbd4e85e88e41c32fa6950b0ef155cf465a80daea1afc87198f55a','2026-05-19 13:09:43','2026-05-19 13:12:14','DA_DANG_XUAT'),(36,3,'d62a2218a8e12e9d93c6d63d946d703057caa69def15577d1f32e7dbd59199a9','2026-05-19 13:09:51','2026-05-19 13:48:33','DA_DANG_XUAT'),(37,110,'68c069ddad0e582cf761446968bffa7bed9c9d58ace43e4d1afc34c7601ad30a','2026-05-19 13:12:24',NULL,'DANG_HOAT_DONG'),(38,2,'699b3843ff3d4aa05d5173fe32170affac92c046672480caf0162456ded2d93e','2026-05-19 13:48:39',NULL,'DANG_HOAT_DONG'),(39,2,'211babc1dee75bcd4a9b3f835747e573604a192876fc0cb8736bfc0295115458','2026-05-19 20:00:36','2026-05-19 22:46:52','DA_DANG_XUAT'),(40,109,'1dc78715f0574ed4bdf69a0b85efde30be895fd17550eb0dacdd822bbd2957fc','2026-05-19 20:00:48',NULL,'DANG_HOAT_DONG'),(41,109,'8357ef473b11732d309567d0fc4b589a0de4b2eb737d5daf874c48fa05acd96c','2026-05-19 20:18:48','2026-05-19 21:07:47','DA_DANG_XUAT'),(42,110,'145b6b3bf488310b50a1297b3132beb15eb94769142b17d6dcfa0b80f4de7091','2026-05-19 21:07:51',NULL,'DANG_HOAT_DONG'),(43,6,'18ad981a7f954830c9451361665a404259a8abe91b8e4be8b528e95152947122','2026-05-19 22:47:16',NULL,'DANG_HOAT_DONG'),(44,6,'da59c1a913136399865dcd380a1615caed592de2d6417a381a34a5d87d02748b','2026-05-20 11:09:30',NULL,'DANG_HOAT_DONG'),(45,6,'c413fecfc0d5082b6bddbc2c94f739164c9c60eed1b583c69e4f51888f9e13a3','2026-05-20 13:46:01',NULL,'DANG_HOAT_DONG'),(46,6,'f8663ac29ff5515ba726f4b7fdfce3363f8a11eb175ab6fbb5fa26af423ac90f','2026-05-20 19:20:36',NULL,'DANG_HOAT_DONG'),(47,6,'6a9b4c014e4bca16b1fe510ce928f237d2e7a1ac4e9fed8206939f20e6df9093','2026-05-20 19:21:19','2026-05-20 19:44:10','DA_DANG_XUAT'),(48,7,'b41e9d1677bdf2eec9699df54672edf36596c44e47d17da66e84c5abea50c54b','2026-05-20 19:44:14','2026-05-20 19:44:25','DA_DANG_XUAT'),(49,7,'682decaba2e5d01f9bcfcea300a4b2a7a73fa76ed95fd8a4b0f906b2a4ed36a1','2026-05-20 19:44:30','2026-05-20 19:44:37','DA_DANG_XUAT'),(50,6,'1d38acd2b322f3c64dd6ccc4f43ee757c1be61ffb046d28951ee696744f37631','2026-05-20 19:44:41','2026-05-20 19:46:37','DA_DANG_XUAT'),(51,7,'8743309b4ed878fb6274d2fc7f396499fb21adefe0cd6856109ed4eb7357a4bf','2026-05-20 19:46:41',NULL,'DANG_HOAT_DONG'),(52,6,'a1fc11e88ba7ca679bdb44723f008646c0136cf34880cee99eebe0ac95a56ef1','2026-05-20 21:13:50',NULL,'DANG_HOAT_DONG');
/*!40000 ALTER TABLE `phiendangnhap` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `phiensinhtran`
--

DROP TABLE IF EXISTS `phiensinhtran`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `phiensinhtran` (
  `idphien` int(11) NOT NULL AUTO_INCREMENT,
  `idgiaidau` int(11) NOT NULL,
  `idvongdau` int(11) NOT NULL,
  `idbangdau` int(11) DEFAULT NULL,
  `kieu_sinh` varchar(50) NOT NULL,
  `pham_vi_sinh` varchar(50) NOT NULL DEFAULT 'VONG_DAU',
  `cach_xep_cap_dau` varchar(50) NOT NULL,
  `tong_tran_du_kien` int(11) DEFAULT NULL,
  `tong_tran_tao` int(11) NOT NULL DEFAULT 0,
  `preview_json` longtext DEFAULT NULL,
  `loi_sinh` varchar(1000) DEFAULT NULL,
  `checksum_cau_hinh` varchar(128) DEFAULT NULL,
  `ghichu` varchar(1000) DEFAULT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'BAN_NHAP',
  `idnguoitao` int(11) DEFAULT NULL,
  `ngaytao` datetime NOT NULL DEFAULT current_timestamp(),
  `ngayxacnhan` datetime DEFAULT NULL,
  PRIMARY KEY (`idphien`),
  KEY `fk_pst_giaidau` (`idgiaidau`),
  KEY `fk_pst_vong` (`idvongdau`),
  KEY `fk_pst_taikhoan` (`idnguoitao`),
  KEY `idx_phiensinhtran_bang` (`idbangdau`),
  CONSTRAINT `fk_phiensinhtran_bangdau` FOREIGN KEY (`idbangdau`) REFERENCES `bangdau` (`idbangdau`) ON DELETE SET NULL,
  CONSTRAINT `fk_pst_giaidau` FOREIGN KEY (`idgiaidau`) REFERENCES `giaidau` (`idgiaidau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_pst_taikhoan` FOREIGN KEY (`idnguoitao`) REFERENCES `taikhoan` (`idtaikhoan`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_pst_vong` FOREIGN KEY (`idvongdau`) REFERENCES `vongdau` (`idvongdau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_pst_kieu` CHECK (`kieu_sinh` in ('VONG_DIEM','VONG_LOAI','CHUNG_KET','TRANH_HANG_BA')),
  CONSTRAINT `chk_pst_cach` CHECK (`cach_xep_cap_dau` in ('RANDOM','SEEDED','POT_DRAW','MANUAL','HYBRID','KHONG_AP_DUNG')),
  CONSTRAINT `chk_phiensinhtran_trangthai` CHECK (`trangthai` in ('BAN_NHAP','NHAP','CHO_XAC_NHAN','DANG_SINH','DA_XAC_NHAN','DA_TAO','THAT_BAI','DA_HUY')),
  CONSTRAINT `chk_phiensinhtran_phamvi` CHECK (`pham_vi_sinh` in ('GIAI_DAU','VONG_DAU','BANG_DAU'))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `phiensinhtran`
--

LOCK TABLES `phiensinhtran` WRITE;
/*!40000 ALTER TABLE `phiensinhtran` DISABLE KEYS */;
/*!40000 ALTER TABLE `phiensinhtran` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quantrivien`
--

DROP TABLE IF EXISTS `quantrivien`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `quantrivien` (
  `idquantrivien` int(11) NOT NULL AUTO_INCREMENT,
  `idnguoidung` int(11) NOT NULL,
  `machucvu` varchar(100) DEFAULT NULL,
  `ghichu` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`idquantrivien`),
  UNIQUE KEY `idnguoidung` (`idnguoidung`),
  CONSTRAINT `fk_qtv_nguoidung` FOREIGN KEY (`idnguoidung`) REFERENCES `nguoidung` (`idnguoidung`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quantrivien`
--

LOCK TABLES `quantrivien` WRITE;
/*!40000 ALTER TABLE `quantrivien` DISABLE KEYS */;
INSERT INTO `quantrivien` VALUES (1,1,'SYS_ADMIN','Quản trị hệ thống');
/*!40000 ALTER TABLE `quantrivien` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quyencapbtc_capgiaidau`
--

DROP TABLE IF EXISTS `quyencapbtc_capgiaidau`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `quyencapbtc_capgiaidau` (
  `idquyen` int(11) NOT NULL AUTO_INCREMENT,
  `idcapbantochuc` int(11) NOT NULL,
  `idcapgiaidau` int(11) NOT NULL,
  `duoc_tao_giai` tinyint(1) NOT NULL DEFAULT 1,
  `duoc_quan_ly` tinyint(1) NOT NULL DEFAULT 1,
  `ghichu` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`idquyen`),
  UNIQUE KEY `uq_quyencapbtc_capgiaidau` (`idcapbantochuc`,`idcapgiaidau`),
  KEY `fk_qcapbtc_capgd` (`idcapgiaidau`),
  CONSTRAINT `fk_qcapbtc_capbtc` FOREIGN KEY (`idcapbantochuc`) REFERENCES `capbantochuc` (`idcapbantochuc`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_qcapbtc_capgd` FOREIGN KEY (`idcapgiaidau`) REFERENCES `capgiaidau` (`idcapgiaidau`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quyencapbtc_capgiaidau`
--

LOCK TABLES `quyencapbtc_capgiaidau` WRITE;
/*!40000 ALTER TABLE `quyencapbtc_capgiaidau` DISABLE KEYS */;
INSERT INTO `quyencapbtc_capgiaidau` VALUES (1,1,1,1,1,'BTC quốc gia tạo giải quốc gia'),(2,2,2,1,1,'BTC tỉnh/thành tạo giải tỉnh/thành'),(3,3,3,1,1,'BTC quận/huyện tạo giải quận/huyện'),(4,4,4,1,1,'BTC đơn vị tạo giải đơn vị');
/*!40000 ALTER TABLE `quyencapbtc_capgiaidau` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quytacchondoi`
--

DROP TABLE IF EXISTS `quytacchondoi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `quytacchondoi` (
  `idquytac` int(11) NOT NULL AUTO_INCREMENT,
  `idgiaidau` int(11) NOT NULL,
  `chedochondoi` varchar(50) NOT NULL DEFAULT 'DANG_KY_THU_CONG',
  `capdoituongthamgia` varchar(50) NOT NULL,
  `yeu_cau_thanh_tich` varchar(50) NOT NULL DEFAULT 'KHONG_YEU_CAU',
  `idcapgiaidau_thanh_tich_nguon` int(11) DEFAULT NULL,
  `hang_toi_thieu_duoc_phep` int(11) DEFAULT NULL,
  `so_mua_giai_gan_nhat_duoc_tinh` int(11) DEFAULT NULL,
  `cho_phep_btc_duyet_ngoai_le` tinyint(1) NOT NULL DEFAULT 1,
  `soluongdoitoida` int(11) DEFAULT NULL,
  `mota` varchar(1000) DEFAULT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'HOAT_DONG',
  PRIMARY KEY (`idquytac`),
  KEY `fk_qtcd_giaidau` (`idgiaidau`),
  KEY `idx_qtcd_capttnguon` (`idcapgiaidau_thanh_tich_nguon`),
  CONSTRAINT `fk_qtcd_capgiaidau_thanh_tich_nguon_v2` FOREIGN KEY (`idcapgiaidau_thanh_tich_nguon`) REFERENCES `capgiaidau` (`idcapgiaidau`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_qtcd_giaidau` FOREIGN KEY (`idgiaidau`) REFERENCES `giaidau` (`idgiaidau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_qtcd_chedo` CHECK (`chedochondoi` in ('DANG_KY_THU_CONG','HE_THONG_GOI_Y','BTC_CHON_THU_CONG','KET_HOP')),
  CONSTRAINT `chk_qtcd_cap` CHECK (`capdoituongthamgia` in ('TINH_THANH','QUAN_HUYEN','XA_PHUONG','DON_VI')),
  CONSTRAINT `chk_qtcd_trangthai` CHECK (`trangthai` in ('HOAT_DONG','NGUNG_SU_DUNG'))
) ENGINE=InnoDB AUTO_INCREMENT=108 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quytacchondoi`
--

LOCK TABLES `quytacchondoi` WRITE;
/*!40000 ALTER TABLE `quytacchondoi` DISABLE KEYS */;
INSERT INTO `quytacchondoi` VALUES (105,105,'KET_HOP','QUAN_HUYEN','TOP_N',3,2,1,1,4,NULL,'HOAT_DONG'),(106,106,'DANG_KY_THU_CONG','TINH_THANH','VO_DICH',2,NULL,1,0,4,NULL,'NGUNG_SU_DUNG'),(107,106,'DANG_KY_THU_CONG','TINH_THANH','VO_DICH',2,NULL,1,0,10,NULL,'HOAT_DONG');
/*!40000 ALTER TABLE `quytacchondoi` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_qtcd_tucach_bi_v2
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_qtcd_tucach_bu_v2
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `role`
--

DROP TABLE IF EXISTS `role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role` (
  `idrole` int(11) NOT NULL AUTO_INCREMENT,
  `namerole` varchar(100) NOT NULL,
  `mota` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`idrole`),
  UNIQUE KEY `namerole` (`namerole`),
  CONSTRAINT `chk_role_namerole` CHECK (`namerole` in ('ADMIN','BAN_TO_CHUC','TRONG_TAI','HUAN_LUYEN_VIEN','VAN_DONG_VIEN','BIEN_TAP'))
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role`
--

LOCK TABLES `role` WRITE;
/*!40000 ALTER TABLE `role` DISABLE KEYS */;
INSERT INTO `role` VALUES (1,'ADMIN','Quản trị viên hệ thống'),(2,'BAN_TO_CHUC','Ban tổ chức giải đấu'),(3,'TRONG_TAI','Trọng tài'),(4,'HUAN_LUYEN_VIEN','Huấn luyện viên'),(5,'VAN_DONG_VIEN','Vận động viên'),(6,'BIEN_TAP','Biên tập viên nội dung');
/*!40000 ALTER TABLE `role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sandau`
--

DROP TABLE IF EXISTS `sandau`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sandau` (
  `idsandau` int(11) NOT NULL AUTO_INCREMENT,
  `idvitrithidau` int(11) NOT NULL,
  `tensandau` varchar(300) NOT NULL,
  `loaisan` varchar(50) NOT NULL DEFAULT 'SAN_BONG_CHUYEN',
  `mat_san` varchar(100) DEFAULT NULL,
  `kichthuoc` varchar(100) DEFAULT NULL,
  `succhua` int(11) NOT NULL DEFAULT 0,
  `mota` varchar(1000) DEFAULT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'HOAT_DONG',
  `ngaytao` datetime NOT NULL DEFAULT current_timestamp(),
  `ngaycapnhat` datetime DEFAULT NULL,
  PRIMARY KEY (`idsandau`),
  UNIQUE KEY `uq_sandau_vitri_ten` (`idvitrithidau`,`tensandau`),
  KEY `idx_sandau_vitri_trangthai` (`idvitrithidau`,`trangthai`),
  KEY `idx_sandau_loaisan_trangthai` (`loaisan`,`trangthai`),
  CONSTRAINT `fk_sandau_vitri` FOREIGN KEY (`idvitrithidau`) REFERENCES `vitrithidau` (`idvitrithidau`) ON UPDATE CASCADE,
  CONSTRAINT `chk_sandau_succhua` CHECK (`succhua` >= 0),
  CONSTRAINT `chk_sandau_trangthai` CHECK (`trangthai` in ('HOAT_DONG','DANG_BAO_TRI','NGUNG_SU_DUNG'))
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sandau`
--

LOCK TABLES `sandau` WRITE;
/*!40000 ALTER TABLE `sandau` DISABLE KEYS */;
INSERT INTO `sandau` VALUES (4,3,'Sân chính Mỹ Đình','SAN_CHINH','Sàn thể thao đa năng','18m x 9m',10000,'Sân chính phục vụ thi đấu.','HOAT_DONG','2026-05-19 22:45:18',NULL),(5,3,'Sân phụ Mỹ Đình 1','SAN_PHU','Sàn thể thao đa năng','18m x 9m',1000,'Sân phụ phục vụ thi đấu hoặc tập luyện.','HOAT_DONG','2026-05-19 22:45:18',NULL),(6,3,'Sân phụ Mỹ Đình 2','SAN_PHU','Sàn thể thao đa năng','18m x 9m',1000,'Sân phụ phục vụ thi đấu hoặc tập luyện.','HOAT_DONG','2026-05-19 22:45:18',NULL),(7,3,'Sân khởi động Mỹ Đình','SAN_KHOI_DONG','Sàn thể thao đa năng','18m x 9m',500,'Sân khởi động trước trận.','HOAT_DONG','2026-05-19 22:45:18',NULL),(8,4,'Sân chính Nhà thi đấu Cầu Giấy','SAN_CHINH','Sàn gỗ','18m x 9m',3000,'Sân chính tại Nhà thi đấu Cầu Giấy.','HOAT_DONG','2026-05-19 22:45:18',NULL),(9,4,'Sân tập Nhà thi đấu Cầu Giấy','SAN_TAP_LUYEN','Sàn gỗ','18m x 9m',500,'Sân tập tại Nhà thi đấu Cầu Giấy.','HOAT_DONG','2026-05-19 22:45:18',NULL),(10,5,'Sân chính Nhà thi đấu Tây Hồ','SAN_CHINH','Sàn gỗ','18m x 9m',2500,'Sân chính tại Nhà thi đấu Tây Hồ.','HOAT_DONG','2026-05-19 22:45:18',NULL),(11,5,'Sân phụ Nhà thi đấu Tây Hồ','SAN_PHU','Sàn gỗ','18m x 9m',500,'Sân phụ tại Nhà thi đấu Tây Hồ.','HOAT_DONG','2026-05-19 22:45:18',NULL);
/*!40000 ALTER TABLE `sandau` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_sandau_bi_strict
BEFORE INSERT ON sandau
FOR EACH ROW
BEGIN
    DECLARE v_trangthai_vitri VARCHAR(50);

    IF NEW.loaisan NOT IN ('SAN_BONG_CHUYEN','SAN_CHINH','SAN_PHU','SAN_KHOI_DONG','SAN_TAP_LUYEN','KHAC') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loại sân không hợp lệ.';
    END IF;

    IF NEW.succhua < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sức chứa sân đấu không được âm.';
    END IF;

    SELECT trangthai INTO v_trangthai_vitri
    FROM vitrithidau
    WHERE idvitrithidau = NEW.idvitrithidau;

    IF NEW.trangthai = 'HOAT_DONG' AND v_trangthai_vitri <> 'HOAT_DONG' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không thể kích hoạt sân thuộc vị trí thi đấu không hoạt động.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_sandau_bu_strict
BEFORE UPDATE ON sandau
FOR EACH ROW
BEGIN
    DECLARE v_trangthai_vitri VARCHAR(50);

    IF NEW.loaisan NOT IN ('SAN_BONG_CHUYEN','SAN_CHINH','SAN_PHU','SAN_KHOI_DONG','SAN_TAP_LUYEN','KHAC') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loại sân không hợp lệ.';
    END IF;

    IF NEW.succhua < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sức chứa sân đấu không được âm.';
    END IF;

    SELECT trangthai INTO v_trangthai_vitri
    FROM vitrithidau
    WHERE idvitrithidau = NEW.idvitrithidau;

    IF NEW.trangthai = 'HOAT_DONG' AND v_trangthai_vitri <> 'HOAT_DONG' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không thể kích hoạt sân thuộc vị trí thi đấu không hoạt động.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `suatthamdu`
--

DROP TABLE IF EXISTS `suatthamdu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `suatthamdu` (
  `idsuat` int(11) NOT NULL AUTO_INCREMENT,
  `idgiaidau_nguon` int(11) DEFAULT NULL,
  `idgiaidau_dich` int(11) NOT NULL,
  `idcapgiaidau_nguon` int(11) DEFAULT NULL,
  `idcapgiaidau_dich` int(11) NOT NULL,
  `idkhuvucphamvi` int(11) DEFAULT NULL,
  `loaisuat` varchar(50) NOT NULL,
  `soluongsuat` int(11) NOT NULL DEFAULT 1,
  `hang_toi_thieu` int(11) DEFAULT NULL,
  `tieuchi_mota` varchar(1000) DEFAULT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'MO',
  `ngaytao` datetime NOT NULL DEFAULT current_timestamp(),
  `ngaycapnhat` datetime DEFAULT NULL,
  PRIMARY KEY (`idsuat`),
  KEY `idx_suat_giai_nguon` (`idgiaidau_nguon`),
  KEY `idx_suat_giai_dich` (`idgiaidau_dich`),
  KEY `idx_suat_cap` (`idcapgiaidau_nguon`,`idcapgiaidau_dich`),
  KEY `idx_suat_khuvuc` (`idkhuvucphamvi`),
  KEY `fk_suat_cap_dich_v2` (`idcapgiaidau_dich`),
  CONSTRAINT `fk_suat_cap_dich_v2` FOREIGN KEY (`idcapgiaidau_dich`) REFERENCES `capgiaidau` (`idcapgiaidau`) ON UPDATE CASCADE,
  CONSTRAINT `fk_suat_cap_nguon_v2` FOREIGN KEY (`idcapgiaidau_nguon`) REFERENCES `capgiaidau` (`idcapgiaidau`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_suat_giai_dich_v2` FOREIGN KEY (`idgiaidau_dich`) REFERENCES `giaidau` (`idgiaidau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_suat_giai_nguon_v2` FOREIGN KEY (`idgiaidau_nguon`) REFERENCES `giaidau` (`idgiaidau`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_suat_khuvuc_v2` FOREIGN KEY (`idkhuvucphamvi`) REFERENCES `khuvuc` (`idkhuvuc`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_suat_loai_v2` CHECK (`loaisuat` in ('VO_DICH_CAP_DUOI','A_QUAN_CAP_DUOI','HANG_BA_CAP_DUOI','TOP_N_CAP_DUOI','XEP_HANG','BTC_CHON','DAC_CACH')),
  CONSTRAINT `chk_suat_soluong_v2` CHECK (`soluongsuat` >= 1),
  CONSTRAINT `chk_suat_hang_v2` CHECK (`hang_toi_thieu` is null or `hang_toi_thieu` >= 1),
  CONSTRAINT `chk_suat_trangthai_v2` CHECK (`trangthai` in ('MO','DA_SU_DUNG','HET_HAN','HUY')),
  CONSTRAINT `chk_suat_topn_v2` CHECK (`loaisuat` <> 'TOP_N_CAP_DUOI' or `hang_toi_thieu` is not null and `hang_toi_thieu` >= 1)
) ENGINE=InnoDB AUTO_INCREMENT=105 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `suatthamdu`
--

LOCK TABLES `suatthamdu` WRITE;
/*!40000 ALTER TABLE `suatthamdu` DISABLE KEYS */;
/*!40000 ALTER TABLE `suatthamdu` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_suatthamdu_bi_v2
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_suatthamdu_bu_v2
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `sukientrandau`
--

DROP TABLE IF EXISTS `sukientrandau`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sukientrandau` (
  `idsukien` int(11) NOT NULL AUTO_INCREMENT,
  `idtrandau` int(11) NOT NULL,
  `loaisukien` varchar(100) NOT NULL,
  `thoigian` datetime NOT NULL DEFAULT current_timestamp(),
  `noidung` varchar(1000) NOT NULL,
  `idnguoitao` int(11) DEFAULT NULL,
  PRIMARY KEY (`idsukien`),
  KEY `fk_sktd_tran` (`idtrandau`),
  KEY `fk_sktd_taikhoan` (`idnguoitao`),
  CONSTRAINT `fk_sktd_taikhoan` FOREIGN KEY (`idnguoitao`) REFERENCES `taikhoan` (`idtaikhoan`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_sktd_tran` FOREIGN KEY (`idtrandau`) REFERENCES `trandau` (`idtrandau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_sktd_loai` CHECK (`loaisukien` in ('BAT_DAU','TAM_DUNG','TIEP_TUC','KET_THUC','SU_CO','GHI_NHAN_DIEM'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sukientrandau`
--

LOCK TABLES `sukientrandau` WRITE;
/*!40000 ALTER TABLE `sukientrandau` DISABLE KEYS */;
/*!40000 ALTER TABLE `sukientrandau` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `taikhoan`
--

DROP TABLE IF EXISTS `taikhoan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `taikhoan` (
  `idtaikhoan` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(150) NOT NULL,
  `sodienthoai` varchar(20) DEFAULT NULL,
  `idrole` int(11) NOT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'CHUA_KICH_HOAT',
  `ngaytao` datetime NOT NULL DEFAULT current_timestamp(),
  `ngaycapnhat` datetime DEFAULT NULL,
  PRIMARY KEY (`idtaikhoan`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `sodienthoai` (`sodienthoai`),
  KEY `fk_taikhoan_role` (`idrole`),
  CONSTRAINT `fk_taikhoan_role` FOREIGN KEY (`idrole`) REFERENCES `role` (`idrole`) ON UPDATE CASCADE,
  CONSTRAINT `chk_taikhoan_trangthai` CHECK (`trangthai` in ('HOAT_DONG','CHUA_KICH_HOAT','TAM_KHOA','DA_HUY','CHO_DUYET')),
  CONSTRAINT `chk_taikhoan_email` CHECK (`email` like '%@%')
) ENGINE=InnoDB AUTO_INCREMENT=125 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `taikhoan`
--

LOCK TABLES `taikhoan` WRITE;
/*!40000 ALTER TABLE `taikhoan` DISABLE KEYS */;
INSERT INTO `taikhoan` VALUES (1,'admin','$2y$10$2MxeQIee/Vf7B6R3DDbkge3lKjLm2sNjVLmW5HD28dUIgDSrAMjFm','admin@vtms.vn','0900000001',1,'HOAT_DONG','2026-05-17 16:49:33',NULL),(2,'btc_quocgia','$2y$10$OBXJKXgj9/3ht4mUK4rQb.SuXMd6rbqObYTDGMGpVzuYSgNT5DSY.','btc.quocgia@vtms.vn','0900000002',2,'HOAT_DONG','2026-05-17 16:49:33',NULL),(3,'btc_hcm','$2y$10$m5vRzWBL/Qg29A4Fysndh.yck4Z4H4ia9AWwRG5D58xzeJYayahKG','btc.hcm@vtms.vn','0900000003',2,'HOAT_DONG','2026-05-17 16:49:33',NULL),(4,'btc_govap','$2y$10$zwD2YFXE.BNHCe7wbRQB4e269EqgN/s7gcpYJmzrvAjbb0CmDhzP.','btc.govap@vtms.vn','0900000004',2,'HOAT_DONG','2026-05-17 16:49:33',NULL),(5,'btc_iuh','$2y$10$LbcnGxDL1zlKUuq1yPsdw.ihAx9OEywBMxvcMQtJGlwFV8R6GYuG6','btc.iuh@vtms.vn','0900000005',2,'HOAT_DONG','2026-05-17 16:49:33',NULL),(6,'ref_01','$2y$10$/mb1U9yUqgxW3MUVp51/PObdmHJIi252.RRsvKeGhzqq2xpeTbGyu','ref01@vtms.vn','0900000006',3,'HOAT_DONG','2026-05-17 16:49:33',NULL),(7,'ref_02','$2y$10$anjKVowmkQYK.TjZ35la0eQQAPhutkOvfpRc8VJL7Yb9E26pS2S8y','ref02@vtms.vn','0900000007',3,'HOAT_DONG','2026-05-17 16:49:33',NULL),(8,'hlv_hcm','$2y$10$.Ca7DM1fbv0rwVoFMrMIteK1NnwD58sWAm7/KPz23riYeFTRaAzri','hlv.hcm@vtms.vn','0900000008',4,'HOAT_DONG','2026-05-17 16:49:33',NULL),(9,'hlv_hn','$2y$10$kl/CO.sa7Lf6P79/CKO2HOHNTArTa6mvehMISb.CpkjcPpckv0ila','hlv.hn@vtms.vn','0900000009',4,'HOAT_DONG','2026-05-17 16:49:33',NULL),(10,'hlv_dn','$2y$10$qkM5X4gdud7IwcGU9iHZLOotYXnNqu2EEAXHN28X/lVe/114SM62e','hlv.dn@vtms.vn','0900000010',4,'HOAT_DONG','2026-05-17 16:49:33',NULL),(11,'hlv_ct','$2y$10$CftvRaET2BctRI/mvucoF.GXZM5r.dbRftZEFY1ykU.NtUyLx.JWi','hlv.ct@vtms.vn','0900000011',4,'HOAT_DONG','2026-05-17 16:49:33',NULL),(12,'vdv_01','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv01@vtms.vn','0900000012',5,'HOAT_DONG','2026-05-17 16:49:33',NULL),(13,'vdv_02','$2y$10$Pa.U/A1gK8liFdpm1ysR5.VnxUv9mV7vuchBEg2wfYX6HI.fqq5Ze','vdv02@vtms.vn','0900000013',5,'HOAT_DONG','2026-05-17 16:49:33',NULL),(14,'vdv_03','$2y$10$snv78agISE3X6AbETkCHQ.9WtAddXU8awYDnoAO1VcPDxYFbbsOFG','vdv03@vtms.vn','0900000014',5,'HOAT_DONG','2026-05-17 16:49:33',NULL),(15,'vdv_04','$2y$10$ukHxJ4quGbM7y4QXTzLSa.5u9i5W3DvCK0MZ7b6CdOSmJdiG0x5nO','vdv04@vtms.vn','0900000015',5,'HOAT_DONG','2026-05-17 16:49:33',NULL),(16,'vdv_05','$2y$10$YbfYRTDsfBMzVCYWNWeWTOkLzztiAml5FpqG6HakL58IBiIalg6j2','vdv05@vtms.vn','0900000016',5,'HOAT_DONG','2026-05-17 16:49:33',NULL),(17,'vdv_06','$2y$10$/ULY3uPx.k3kjSuAn/TvaeQQ.tDDYcKX4A/7gp8wk2PFtKMHmDfbi','vdv06@vtms.vn','0900000017',5,'HOAT_DONG','2026-05-17 16:49:33',NULL),(18,'vdv_07','$2y$10$lafc4O90H.mrRLcdMFmTg.BfDfMMO/3ZQ9icUbddGC0nULMIoq3ta','vdv07@vtms.vn','0900000018',5,'HOAT_DONG','2026-05-17 16:49:33',NULL),(19,'vdv_08','$2y$10$Fme7tUfR2wTQFpBz2RsO7.3LQthIpvdLjX2kNkZr0UmBjq8p0YIye','vdv08@vtms.vn','0900000019',5,'HOAT_DONG','2026-05-17 16:49:33',NULL),(101,'btc_q1','hashed_btc','btc.q1@vtms.vn','0900000101',2,'HOAT_DONG','2026-05-17 16:49:43',NULL),(102,'btc_q12','hashed_btc','btc.q12@vtms.vn','0900000102',2,'HOAT_DONG','2026-05-17 16:49:43',NULL),(103,'btc_binhthanh','hashed_btc','btc.binhthanh@vtms.vn','0900000103',2,'HOAT_DONG','2026-05-17 16:49:43',NULL),(109,'hlv_bao_hcm','$2y$10$dsg6WOzW8c3/mEu0fwo6IeDysCaFLgX1NvaWKE.zuEDH3YgAw1Lxy','phubao12as@gmail.com','0355281276',4,'HOAT_DONG','2026-05-18 13:23:36','2026-05-18 13:24:39'),(110,'hlv_nhi_hn','$2y$10$ec7udZg73GLdIeO9/g1Qz.TdahFv82dT2UW1qkAWv6TouViD2dzLS','yenjj2022@gmail.com','0355281277',4,'HOAT_DONG','2026-05-18 13:26:33','2026-05-18 13:26:54'),(113,'thanhvienA','$2y$10$AsYrKkhRxRi9X6fCOtkh4egf/Xc9uulamPERnMy9WuAvFHavchL9K','a@gmail.com','0123456789',5,'HOAT_DONG','2026-05-18 14:09:45',NULL),(114,'thanhvienB','$2y$10$VfPgcGPy.6TbmIrgxpZEFe0vFjFG4q2JD.XFjES53J06l0np0d3LS','b@gmail.com','0123456788',5,'HOAT_DONG','2026-05-18 14:10:31',NULL),(115,'thanhvienC','$2y$10$YiL/7YqkkiNyl8MNhgsVEO/ZCDA8qFaQWVFZm9JOavqYEs1TzzKaG','c@gmail.com','0123456787',5,'HOAT_DONG','2026-05-18 14:10:52',NULL),(116,'thanhvienD','$2y$10$CpILJidF39aSnOOYeqDFqeL0sIn.d284DSgWNmqkyWaZfrCg9M1GC','d@gmail.com','0123456786',5,'HOAT_DONG','2026-05-18 14:11:07',NULL),(117,'thanhvienE','$2y$10$Ttls14BT1tgGysgkCGE5Y.58nyKd.Otq/xOS4IL7RwZvZhmbh1fg2','e@gmail.com','0123456785',5,'HOAT_DONG','2026-05-18 14:11:21',NULL),(118,'thanhvienF','$2y$10$kyHDEasx0JUJcKJbkCsv1OAfQPYXxU6drtj8m4PdUoGmnUUKsIrWi','f@gmail.com','0123456784',5,'HOAT_DONG','2026-05-18 14:11:36',NULL),(119,'Thanhvien1','$2y$10$QDLrLOrd4bfhsI.9KB6Jmu1YH.GzKI4k4BcKYWmKG0fYGeU8ryA3W','1@gmail.com','0111111111',5,'HOAT_DONG','2026-05-19 13:15:27',NULL),(120,'Thanhvien2','$2y$10$zYfHC5RW1YFO7CAAphku3Orr7iqc.QId6cFRna48VadudamYWH0nq','2@gmail.com','0111111112',5,'HOAT_DONG','2026-05-19 13:16:30',NULL),(121,'Thanhvien3','$2y$10$SDtoQgPnN/Tx7dqtN7AVBexcU.9ahKWcNMycz6B/9dbk5PJotwl4y','3@gmail.com','0111111113',5,'HOAT_DONG','2026-05-19 13:16:46',NULL),(122,'Thanhvien4','$2y$10$BMu8oJCmJP6oxJBsvR.iOOyXrKbk.i//3DddVDwnDKjcRtKIgg4xy','4@gmail.com','0111111114',5,'HOAT_DONG','2026-05-19 13:16:59',NULL),(123,'Thanhvien5','$2y$10$XtVmTfXVuSKQUkoh314SHu/U9aJqUJS2lv1HErW4mTNzj2w8a0SH.','5@gmail.com','0111111115',5,'HOAT_DONG','2026-05-19 13:17:11',NULL),(124,'Thanhvien6','$2y$10$ZM8cBCKUBPgEFsBKKBmNEuB5oxagdlNHIvZRh/Kclw6UWX8ZHvcym','6@gmail.com','0111111116',5,'HOAT_DONG','2026-05-19 13:17:23',NULL);
/*!40000 ALTER TABLE `taikhoan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `thanhtichdoibong`
--

DROP TABLE IF EXISTS `thanhtichdoibong`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `thanhtichdoibong` (
  `idthanhtich` int(11) NOT NULL AUTO_INCREMENT,
  `iddoibong` int(11) NOT NULL,
  `idgiaidau` int(11) NOT NULL,
  `idvongdau` int(11) DEFAULT NULL,
  `idbangxephang` int(11) DEFAULT NULL,
  `idchitietbxh` int(11) DEFAULT NULL,
  `idcapgiaidau` int(11) NOT NULL,
  `idkhuvuc` int(11) NOT NULL,
  `mua_giai` int(11) NOT NULL,
  `hang_dat_duoc` int(11) NOT NULL,
  `danhhieu` varchar(50) NOT NULL,
  `ngay_cong_nhan` date NOT NULL,
  `nguon_ghi_nhan` varchar(50) NOT NULL DEFAULT 'BANG_XEP_HANG',
  `ghi_chu` varchar(1000) DEFAULT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'HOP_LE',
  `ngaytao` datetime NOT NULL DEFAULT current_timestamp(),
  `ngaycapnhat` datetime DEFAULT NULL,
  PRIMARY KEY (`idthanhtich`),
  UNIQUE KEY `uq_tt_doi_giai_danhhieu` (`iddoibong`,`idgiaidau`,`danhhieu`),
  KEY `idx_tt_doi` (`iddoibong`),
  KEY `idx_tt_giai` (`idgiaidau`),
  KEY `idx_tt_cap_hang` (`idcapgiaidau`,`hang_dat_duoc`),
  KEY `idx_tt_mua` (`mua_giai`),
  KEY `idx_tt_khuvuc` (`idkhuvuc`),
  KEY `idx_tt_ctbxh` (`idchitietbxh`),
  KEY `fk_tt_vong_v2` (`idvongdau`),
  KEY `fk_tt_bxh_v2` (`idbangxephang`),
  CONSTRAINT `fk_tt_bxh_v2` FOREIGN KEY (`idbangxephang`) REFERENCES `bangxephang` (`idbangxephang`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_tt_cap_v2` FOREIGN KEY (`idcapgiaidau`) REFERENCES `capgiaidau` (`idcapgiaidau`) ON UPDATE CASCADE,
  CONSTRAINT `fk_tt_ctbxh_v2` FOREIGN KEY (`idchitietbxh`) REFERENCES `chitietbangxephang` (`idchitietbxh`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_tt_doi_v2` FOREIGN KEY (`iddoibong`) REFERENCES `doibong` (`iddoibong`) ON UPDATE CASCADE,
  CONSTRAINT `fk_tt_giai_v2` FOREIGN KEY (`idgiaidau`) REFERENCES `giaidau` (`idgiaidau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_tt_khuvuc_v2` FOREIGN KEY (`idkhuvuc`) REFERENCES `khuvuc` (`idkhuvuc`) ON UPDATE CASCADE,
  CONSTRAINT `fk_tt_vong_v2` FOREIGN KEY (`idvongdau`) REFERENCES `vongdau` (`idvongdau`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_tt_mua_v2` CHECK (`mua_giai` between 2000 and 2100),
  CONSTRAINT `chk_tt_hang_v2` CHECK (`hang_dat_duoc` >= 1),
  CONSTRAINT `chk_tt_danhhieu_v2` CHECK (`danhhieu` in ('VO_DICH','A_QUAN','HANG_BA','TOP_4','TOP_8','THAM_DU','KHAC')),
  CONSTRAINT `chk_tt_nguon_v2` CHECK (`nguon_ghi_nhan` in ('BANG_XEP_HANG','BTC_NHAP_TAY','HE_THONG_TONG_HOP')),
  CONSTRAINT `chk_tt_trangthai_v2` CHECK (`trangthai` in ('HOP_LE','BI_HUY','TAM_TREO'))
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `thanhtichdoibong`
--

LOCK TABLES `thanhtichdoibong` WRITE;
/*!40000 ALTER TABLE `thanhtichdoibong` DISABLE KEYS */;
INSERT INTO `thanhtichdoibong` VALUES (12,18,105,NULL,NULL,NULL,2,2,2026,1,'VO_DICH','2026-05-19','BTC_NHAP_TAY','Seed kiểm thử: Đội super Men là vô địch giải cấp tỉnh/thành.','HOP_LE','2026-05-19 13:30:21',NULL),(13,19,105,NULL,NULL,NULL,2,2,2026,1,'VO_DICH','2026-05-19','BTC_NHAP_TAY','Seed kiểm thử: Đội bóng Thủ đô là vô địch giải cấp tỉnh/thành.','HOP_LE','2026-05-19 13:30:21',NULL);
/*!40000 ALTER TABLE `thanhtichdoibong` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_thanhtichdoibong_bi_v2
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_thanhtichdoibong_bu_v2
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `thanhviendoibong`
--

DROP TABLE IF EXISTS `thanhviendoibong`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `thanhviendoibong` (
  `idthanhvien` int(11) NOT NULL AUTO_INCREMENT,
  `iddoibong` int(11) NOT NULL,
  `idvandongvien` int(11) NOT NULL,
  `vaitro` varchar(100) NOT NULL DEFAULT 'THANH_VIEN',
  `trangthai` varchar(50) NOT NULL DEFAULT 'CHO_XAC_NHAN',
  `ngaythamgia` date NOT NULL,
  `ngayroi` date DEFAULT NULL,
  PRIMARY KEY (`idthanhvien`),
  UNIQUE KEY `uq_tvdb_doi_vdv` (`iddoibong`,`idvandongvien`),
  KEY `fk_tvdb_vdv` (`idvandongvien`),
  CONSTRAINT `fk_tvdb_doibong` FOREIGN KEY (`iddoibong`) REFERENCES `doibong` (`iddoibong`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_tvdb_vdv` FOREIGN KEY (`idvandongvien`) REFERENCES `vandongvien` (`idvandongvien`) ON UPDATE CASCADE,
  CONSTRAINT `chk_tvdb_vaitro` CHECK (`vaitro` in ('DOI_TRUONG','THANH_VIEN','DU_BI')),
  CONSTRAINT `chk_tvdb_trangthai` CHECK (`trangthai` in ('CHO_XAC_NHAN','DANG_THAM_GIA','DA_ROI_DOI','BI_LOAI')),
  CONSTRAINT `chk_tvdb_ngayroi` CHECK (`ngayroi` is null or `ngayroi` >= `ngaythamgia`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `thanhviendoibong`
--

LOCK TABLES `thanhviendoibong` WRITE;
/*!40000 ALTER TABLE `thanhviendoibong` DISABLE KEYS */;
INSERT INTO `thanhviendoibong` VALUES (9,18,11,'DOI_TRUONG','DANG_THAM_GIA','2026-05-18',NULL),(10,18,12,'THANH_VIEN','DANG_THAM_GIA','2026-05-18',NULL),(11,18,13,'THANH_VIEN','DANG_THAM_GIA','2026-05-18',NULL),(12,18,14,'THANH_VIEN','DANG_THAM_GIA','2026-05-18',NULL),(13,18,15,'THANH_VIEN','DANG_THAM_GIA','2026-05-18',NULL),(14,18,16,'THANH_VIEN','DANG_THAM_GIA','2026-05-18',NULL),(15,19,17,'DOI_TRUONG','DANG_THAM_GIA','2026-05-19',NULL),(16,19,18,'THANH_VIEN','DANG_THAM_GIA','2026-05-19',NULL),(17,19,19,'THANH_VIEN','DANG_THAM_GIA','2026-05-19',NULL),(18,19,20,'THANH_VIEN','DANG_THAM_GIA','2026-05-19',NULL),(19,19,21,'THANH_VIEN','DANG_THAM_GIA','2026-05-19',NULL),(20,19,22,'THANH_VIEN','DANG_THAM_GIA','2026-05-19',NULL);
/*!40000 ALTER TABLE `thanhviendoibong` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `thethucgiaidau`
--

DROP TABLE IF EXISTS `thethucgiaidau`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `thethucgiaidau` (
  `idthethuc` int(11) NOT NULL AUTO_INCREMENT,
  `idgiaidau` int(11) NOT NULL,
  `tenthethuc` varchar(300) NOT NULL,
  `tong_so_vong` int(11) NOT NULL DEFAULT 1,
  `co_vong_diem` tinyint(1) NOT NULL DEFAULT 0,
  `co_vong_loai` tinyint(1) NOT NULL DEFAULT 0,
  `co_tranh_hang_ba` tinyint(1) NOT NULL DEFAULT 0,
  `cach_xep_mac_dinh` varchar(50) NOT NULL DEFAULT 'HYBRID',
  `seed_source_mac_dinh` varchar(100) NOT NULL DEFAULT 'BTC_NHAP_TAY',
  `mota` varchar(2000) DEFAULT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'DANG_THIET_LAP',
  PRIMARY KEY (`idthethuc`),
  UNIQUE KEY `idgiaidau` (`idgiaidau`),
  CONSTRAINT `fk_thethuc_giaidau` FOREIGN KEY (`idgiaidau`) REFERENCES `giaidau` (`idgiaidau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_thethuc_vong` CHECK (`tong_so_vong` > 0),
  CONSTRAINT `chk_thethuc_cachxep` CHECK (`cach_xep_mac_dinh` in ('RANDOM','SEEDED','POT_DRAW','MANUAL','HYBRID')),
  CONSTRAINT `chk_thethuc_seed` CHECK (`seed_source_mac_dinh` in ('BANG_XEP_HANG_TRUOC','THU_HANG_VONG_TRUOC','DIEM_TICH_LUY','BTC_NHAP_TAY','KHONG_AP_DUNG')),
  CONSTRAINT `chk_thethuc_trangthai` CHECK (`trangthai` in ('DANG_THIET_LAP','DA_XAC_NHAN','DA_HUY'))
) ENGINE=InnoDB AUTO_INCREMENT=108 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `thethucgiaidau`
--

LOCK TABLES `thethucgiaidau` WRITE;
/*!40000 ALTER TABLE `thethucgiaidau` DISABLE KEYS */;
INSERT INTO `thethucgiaidau` VALUES (105,105,'Vòng loại trực tiếp',1,0,1,1,'HYBRID','BTC_NHAP_TAY',NULL,'DANG_THIET_LAP'),(107,106,'Vòng loại trực tiếp',1,0,1,1,'HYBRID','BTC_NHAP_TAY',NULL,'DANG_THIET_LAP');
/*!40000 ALTER TABLE `thethucgiaidau` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `thongbao`
--

DROP TABLE IF EXISTS `thongbao`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `thongbao` (
  `idthongbao` int(11) NOT NULL AUTO_INCREMENT,
  `idnguoinhan` int(11) NOT NULL,
  `tieude` varchar(300) NOT NULL,
  `noidung` varchar(1000) NOT NULL,
  `loai` varchar(100) NOT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'CHUA_DOC',
  `ngaytao` datetime NOT NULL DEFAULT current_timestamp(),
  `ngaydoc` datetime DEFAULT NULL,
  PRIMARY KEY (`idthongbao`),
  KEY `fk_thongbao_taikhoan` (`idnguoinhan`),
  CONSTRAINT `fk_thongbao_taikhoan` FOREIGN KEY (`idnguoinhan`) REFERENCES `taikhoan` (`idtaikhoan`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_thongbao_loai` CHECK (`loai` in ('HE_THONG','XAC_NHAN','LICH_THI_DAU','KET_QUA','LOI_MOI_DOI_BONG','KHIEU_NAI')),
  CONSTRAINT `chk_thongbao_trangthai` CHECK (`trangthai` in ('CHUA_DOC','DA_DOC','DA_XOA')),
  CONSTRAINT `chk_thongbao_ngaydoc` CHECK (`ngaydoc` is null or `ngaydoc` >= `ngaytao`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `thongbao`
--

LOCK TABLES `thongbao` WRITE;
/*!40000 ALTER TABLE `thongbao` DISABLE KEYS */;
INSERT INTO `thongbao` VALUES (3,8,'Giải đấu mới: Giải quốc gia VN 2026','Giải đấu Giải quốc gia VN 2026 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-19 20:03:42',NULL),(4,9,'Giải đấu mới: Giải quốc gia VN 2026','Giải đấu Giải quốc gia VN 2026 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-19 20:03:42',NULL),(5,10,'Giải đấu mới: Giải quốc gia VN 2026','Giải đấu Giải quốc gia VN 2026 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-19 20:03:42',NULL),(6,11,'Giải đấu mới: Giải quốc gia VN 2026','Giải đấu Giải quốc gia VN 2026 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-19 20:03:42',NULL),(7,109,'Giải đấu mới: Giải quốc gia VN 2026','Giải đấu Giải quốc gia VN 2026 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-19 20:03:42',NULL),(8,110,'Giải đấu mới: Giải quốc gia VN 2026','Giải đấu Giải quốc gia VN 2026 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-19 20:03:42',NULL);
/*!40000 ALTER TABLE `thongbao` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `thongkecanhan`
--

DROP TABLE IF EXISTS `thongkecanhan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `thongkecanhan` (
  `idthongkecanhan` int(11) NOT NULL AUTO_INCREMENT,
  `idvandongvien` int(11) NOT NULL,
  `idgiaidau` int(11) NOT NULL,
  `idtrandau` int(11) NOT NULL,
  `sodiem` int(11) NOT NULL DEFAULT 0,
  `solanphatbong` int(11) NOT NULL DEFAULT 0,
  `solanchanbong` int(11) NOT NULL DEFAULT 0,
  `solanghidiem` int(11) NOT NULL DEFAULT 0,
  `ghichu` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`idthongkecanhan`),
  UNIQUE KEY `uq_tkcn` (`idvandongvien`,`idgiaidau`,`idtrandau`),
  KEY `fk_tkcn_giaidau` (`idgiaidau`),
  KEY `fk_tkcn_tran` (`idtrandau`),
  CONSTRAINT `fk_tkcn_giaidau` FOREIGN KEY (`idgiaidau`) REFERENCES `giaidau` (`idgiaidau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_tkcn_tran` FOREIGN KEY (`idtrandau`) REFERENCES `trandau` (`idtrandau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_tkcn_vdv` FOREIGN KEY (`idvandongvien`) REFERENCES `vandongvien` (`idvandongvien`) ON UPDATE CASCADE,
  CONSTRAINT `chk_tkcn_nonnegative` CHECK (`sodiem` >= 0 and `solanphatbong` >= 0 and `solanchanbong` >= 0 and `solanghidiem` >= 0)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `thongkecanhan`
--

LOCK TABLES `thongkecanhan` WRITE;
/*!40000 ALTER TABLE `thongkecanhan` DISABLE KEYS */;
/*!40000 ALTER TABLE `thongkecanhan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `thongkedoi`
--

DROP TABLE IF EXISTS `thongkedoi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `thongkedoi` (
  `idthongkedoi` int(11) NOT NULL AUTO_INCREMENT,
  `idgiaidau` int(11) NOT NULL,
  `idvongdau` int(11) DEFAULT NULL,
  `idbangdau` int(11) DEFAULT NULL,
  `iddoibong` int(11) NOT NULL,
  `sotran` int(11) NOT NULL DEFAULT 0,
  `sotranthang` int(11) NOT NULL DEFAULT 0,
  `sotranthua` int(11) NOT NULL DEFAULT 0,
  `sosetthang` int(11) NOT NULL DEFAULT 0,
  `sosetthua` int(11) NOT NULL DEFAULT 0,
  `diem` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`idthongkedoi`),
  UNIQUE KEY `uq_tkd_scope` (`idgiaidau`,`idvongdau`,`idbangdau`,`iddoibong`),
  KEY `fk_tkd_vong` (`idvongdau`),
  KEY `fk_tkd_bang` (`idbangdau`),
  KEY `fk_tkd_doi` (`iddoibong`),
  CONSTRAINT `fk_tkd_bang` FOREIGN KEY (`idbangdau`) REFERENCES `bangdau` (`idbangdau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_tkd_doi` FOREIGN KEY (`iddoibong`) REFERENCES `doibong` (`iddoibong`) ON UPDATE CASCADE,
  CONSTRAINT `fk_tkd_giaidau` FOREIGN KEY (`idgiaidau`) REFERENCES `giaidau` (`idgiaidau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_tkd_vong` FOREIGN KEY (`idvongdau`) REFERENCES `vongdau` (`idvongdau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_tkd_nonnegative` CHECK (`sotran` >= 0 and `sotranthang` >= 0 and `sotranthua` >= 0 and `sosetthang` >= 0 and `sosetthua` >= 0 and `diem` >= 0),
  CONSTRAINT `chk_tkd_tongtran` CHECK (`sotran` >= `sotranthang` + `sotranthua`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `thongkedoi`
--

LOCK TABLES `thongkedoi` WRITE;
/*!40000 ALTER TABLE `thongkedoi` DISABLE KEYS */;
/*!40000 ALTER TABLE `thongkedoi` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trandau`
--

DROP TABLE IF EXISTS `trandau`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trandau` (
  `idtrandau` int(11) NOT NULL AUTO_INCREMENT,
  `idgiaidau` int(11) NOT NULL,
  `idvongdau` int(11) NOT NULL,
  `idbangdau` int(11) DEFAULT NULL,
  `idphien` int(11) DEFAULT NULL,
  `ma_tran` varchar(100) NOT NULL,
  `ten_tran` varchar(300) DEFAULT NULL,
  `loaitrandau` varchar(50) NOT NULL DEFAULT 'VONG_DIEM',
  `iddoibong1` int(11) DEFAULT NULL,
  `iddoibong2` int(11) DEFAULT NULL,
  `idvitrithidau` int(11) DEFAULT NULL,
  `idsandau` int(11) DEFAULT NULL,
  `thoigianbatdau` datetime DEFAULT NULL,
  `thoigianketthuc` datetime DEFAULT NULL,
  `thutu_tran` int(11) NOT NULL,
  `vong_so` int(11) DEFAULT NULL,
  `luot_dau` int(11) NOT NULL DEFAULT 1,
  `idtrandau_thang_tiep` int(11) DEFAULT NULL,
  `slot_thang_tiep` int(11) DEFAULT NULL,
  `idtrandau_thua_tiep` int(11) DEFAULT NULL,
  `slot_thua_tiep` int(11) DEFAULT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'CHO_DOI_DOI',
  `ngaytao` datetime NOT NULL DEFAULT current_timestamp(),
  `ngaycapnhat` datetime DEFAULT NULL,
  PRIMARY KEY (`idtrandau`),
  UNIQUE KEY `uq_trandau_ma` (`idgiaidau`,`ma_tran`),
  KEY `idx_trandau_vong` (`idvongdau`),
  KEY `idx_trandau_doi1` (`iddoibong1`),
  KEY `idx_trandau_doi2` (`iddoibong2`),
  KEY `fk_trandau_san` (`idsandau`),
  KEY `idx_trandau_phien` (`idphien`),
  KEY `idx_trandau_vitri` (`idvitrithidau`),
  KEY `idx_trandau_bang_trangthai` (`idbangdau`,`trangthai`,`thoigianbatdau`),
  KEY `idx_trandau_vong_loai` (`idvongdau`,`loaitrandau`,`vong_so`,`thutu_tran`),
  KEY `idx_trandau_tiep_thang` (`idtrandau_thang_tiep`),
  KEY `idx_trandau_tiep_thua` (`idtrandau_thua_tiep`),
  CONSTRAINT `fk_trandau_bang` FOREIGN KEY (`idbangdau`) REFERENCES `bangdau` (`idbangdau`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_trandau_doi1` FOREIGN KEY (`iddoibong1`) REFERENCES `doibong` (`iddoibong`) ON UPDATE CASCADE,
  CONSTRAINT `fk_trandau_doi2` FOREIGN KEY (`iddoibong2`) REFERENCES `doibong` (`iddoibong`) ON UPDATE CASCADE,
  CONSTRAINT `fk_trandau_giaidau` FOREIGN KEY (`idgiaidau`) REFERENCES `giaidau` (`idgiaidau`) ON UPDATE CASCADE,
  CONSTRAINT `fk_trandau_phiensinhtran` FOREIGN KEY (`idphien`) REFERENCES `phiensinhtran` (`idphien`) ON DELETE SET NULL,
  CONSTRAINT `fk_trandau_san` FOREIGN KEY (`idsandau`) REFERENCES `sandau` (`idsandau`) ON UPDATE CASCADE,
  CONSTRAINT `fk_trandau_thang_tiep` FOREIGN KEY (`idtrandau_thang_tiep`) REFERENCES `trandau` (`idtrandau`) ON DELETE SET NULL,
  CONSTRAINT `fk_trandau_thua_tiep` FOREIGN KEY (`idtrandau_thua_tiep`) REFERENCES `trandau` (`idtrandau`) ON DELETE SET NULL,
  CONSTRAINT `fk_trandau_vitrithidau` FOREIGN KEY (`idvitrithidau`) REFERENCES `vitrithidau` (`idvitrithidau`) ON DELETE SET NULL,
  CONSTRAINT `fk_trandau_vong` FOREIGN KEY (`idvongdau`) REFERENCES `vongdau` (`idvongdau`) ON UPDATE CASCADE,
  CONSTRAINT `chk_trandau_2doi` CHECK (`iddoibong1` is null or `iddoibong2` is null or `iddoibong1` <> `iddoibong2`),
  CONSTRAINT `chk_trandau_thoigian` CHECK (`thoigianketthuc` is null or `thoigianbatdau` is null or `thoigianketthuc` > `thoigianbatdau`),
  CONSTRAINT `chk_trandau_thutu` CHECK (`thutu_tran` > 0),
  CONSTRAINT `chk_trandau_trangthai` CHECK (`trangthai` in ('CHUA_XAC_DINH_DOI','CHO_DOI_DOI','CHO_XEP_LICH','DA_SAN_SANG','DA_XEP_LICH','SAP_DIEN_RA','DANG_DIEN_RA','TAM_DUNG','DA_KET_THUC','DA_HUY')),
  CONSTRAINT `chk_trandau_loaitrandau` CHECK (`loaitrandau` in ('VONG_DIEM','LOAI_TRUC_TIEP','GIAO_HUU','TRANH_HANG_BA','CHUNG_KET')),
  CONSTRAINT `chk_trandau_luot_vong` CHECK (`luot_dau` >= 1 and (`vong_so` is null or `vong_so` >= 1)),
  CONSTRAINT `chk_trandau_slot_tiep` CHECK ((`slot_thang_tiep` is null or `slot_thang_tiep` in (1,2)) and (`slot_thua_tiep` is null or `slot_thua_tiep` in (1,2)))
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trandau`
--

LOCK TABLES `trandau` WRITE;
/*!40000 ALTER TABLE `trandau` DISABLE KEYS */;
INSERT INTO `trandau` VALUES (17,106,7,NULL,NULL,'R7-20260519224639',NULL,'VONG_DIEM',19,18,NULL,4,'2026-06-02 09:00:00',NULL,1,NULL,1,NULL,NULL,NULL,NULL,'DA_XEP_LICH','2026-05-19 22:46:39',NULL);
/*!40000 ALTER TABLE `trandau` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_trandau_bi
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
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tr?n ??u ph?i thu?c ??ng gi?i c?a v?ng ??u.';
    END IF;

    IF v_cobang = 0 AND NEW.idbangdau IS NOT NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'V?ng kh?ng c? b?ng ??u th? tr?n ??u kh?ng ???c g?n b?ng ??u.';
    END IF;

    IF NEW.idbangdau IS NOT NULL THEN
        SELECT idvongdau
          INTO v_bang_vong
          FROM bangdau
         WHERE idbangdau = NEW.idbangdau;

        IF v_bang_vong <> NEW.idvongdau THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'B?ng ??u c?a tr?n ph?i thu?c ??ng v?ng ??u.';
        END IF;
    END IF;

    IF NEW.iddoibong1 IS NOT NULL THEN
        SELECT COUNT(*)
          INTO v_count
          FROM doitrongvongdau
         WHERE idvongdau = NEW.idvongdau
           AND iddoibong = NEW.iddoibong1;

        IF v_count = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '??i 1 kh?ng thu?c v?ng ??u.';
        END IF;
    END IF;

    IF NEW.iddoibong2 IS NOT NULL THEN
        SELECT COUNT(*)
          INTO v_count
          FROM doitrongvongdau
         WHERE idvongdau = NEW.idvongdau
           AND iddoibong = NEW.iddoibong2;

        IF v_count = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '??i 2 kh?ng thu?c v?ng ??u.';
        END IF;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `trandauslot`
--

DROP TABLE IF EXISTS `trandauslot`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trandauslot` (
  `idslot` int(11) NOT NULL AUTO_INCREMENT,
  `idtrandau` int(11) NOT NULL,
  `slot_so` int(11) NOT NULL,
  `slot_label` varchar(100) DEFAULT NULL,
  `source_type` varchar(50) NOT NULL DEFAULT 'TEAM',
  `iddoibong` int(11) DEFAULT NULL,
  `source_match_id` int(11) DEFAULT NULL,
  `source_result` varchar(20) DEFAULT NULL,
  `resolved_at` datetime DEFAULT NULL,
  `ngaycapnhat` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  `source_seed_no` int(11) DEFAULT NULL,
  `ghichu` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`idslot`),
  UNIQUE KEY `uq_slot_tran` (`idtrandau`,`slot_so`),
  KEY `fk_slot_doi` (`iddoibong`),
  KEY `fk_slot_source_match` (`source_match_id`),
  KEY `idx_trandauslot_source` (`source_type`,`source_match_id`,`source_result`),
  CONSTRAINT `fk_slot_doi` FOREIGN KEY (`iddoibong`) REFERENCES `doibong` (`iddoibong`) ON UPDATE CASCADE,
  CONSTRAINT `fk_slot_source_match` FOREIGN KEY (`source_match_id`) REFERENCES `trandau` (`idtrandau`) ON UPDATE CASCADE,
  CONSTRAINT `fk_slot_tran` FOREIGN KEY (`idtrandau`) REFERENCES `trandau` (`idtrandau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_slot_so` CHECK (`slot_so` in (1,2)),
  CONSTRAINT `chk_slot_source_type` CHECK (`source_type` in ('TEAM','WINNER','LOSER','SEED','BYE')),
  CONSTRAINT `chk_slot_source_result` CHECK (`source_result` is null or `source_result` in ('WINNER','LOSER')),
  CONSTRAINT `chk_slot_seed` CHECK (`source_seed_no` is null or `source_seed_no` > 0)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trandauslot`
--

LOCK TABLES `trandauslot` WRITE;
/*!40000 ALTER TABLE `trandauslot` DISABLE KEYS */;
INSERT INTO `trandauslot` VALUES (31,17,1,NULL,'TEAM',19,NULL,NULL,NULL,NULL,NULL,NULL),(32,17,2,NULL,'TEAM',18,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `trandauslot` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_trandauslot_bi
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `trongtai`
--

DROP TABLE IF EXISTS `trongtai`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trongtai` (
  `idtrongtai` int(11) NOT NULL AUTO_INCREMENT,
  `idnguoidung` int(11) NOT NULL,
  `capbac` varchar(100) DEFAULT NULL,
  `kinhnghiem` int(11) NOT NULL DEFAULT 0,
  `trangthai` varchar(50) NOT NULL DEFAULT 'CHO_DUYET',
  PRIMARY KEY (`idtrongtai`),
  UNIQUE KEY `idnguoidung` (`idnguoidung`),
  CONSTRAINT `fk_trongtai_nguoidung` FOREIGN KEY (`idnguoidung`) REFERENCES `nguoidung` (`idnguoidung`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_trongtai_kinhnghiem` CHECK (`kinhnghiem` >= 0),
  CONSTRAINT `chk_trongtai_trangthai` CHECK (`trangthai` in ('HOAT_DONG','CHO_DUYET','DANG_NGHI','NGUNG_HOAT_DONG'))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trongtai`
--

LOCK TABLES `trongtai` WRITE;
/*!40000 ALTER TABLE `trongtai` DISABLE KEYS */;
INSERT INTO `trongtai` VALUES (1,6,'Cấp quốc gia',10,'HOAT_DONG'),(2,7,'Cấp thành phố',6,'HOAT_DONG');
/*!40000 ALTER TABLE `trongtai` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trongtaitrandau`
--

DROP TABLE IF EXISTS `trongtaitrandau`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trongtaitrandau` (
  `idtrongtaitrandau` int(11) NOT NULL AUTO_INCREMENT,
  `idtrandau` int(11) NOT NULL,
  `idtrongtai` int(11) NOT NULL,
  `vaitro` varchar(100) NOT NULL,
  `xacnhanthamgia` tinyint(1) NOT NULL DEFAULT 0,
  `thoigianxacnhan` datetime DEFAULT NULL,
  PRIMARY KEY (`idtrongtaitrandau`),
  UNIQUE KEY `uq_tttd` (`idtrandau`,`idtrongtai`),
  KEY `fk_tttd_trongtai` (`idtrongtai`),
  CONSTRAINT `fk_tttd_tran` FOREIGN KEY (`idtrandau`) REFERENCES `trandau` (`idtrandau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_tttd_trongtai` FOREIGN KEY (`idtrongtai`) REFERENCES `trongtai` (`idtrongtai`) ON UPDATE CASCADE,
  CONSTRAINT `chk_tttd_vaitro` CHECK (`vaitro` in ('TRONG_TAI_CHINH','TRONG_TAI_PHU','GIAM_SAT')),
  CONSTRAINT `chk_tttd_xacnhan` CHECK (`xacnhanthamgia` = 0 and `thoigianxacnhan` is null or `xacnhanthamgia` = 1 and `thoigianxacnhan` is not null)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trongtaitrandau`
--

LOCK TABLES `trongtaitrandau` WRITE;
/*!40000 ALTER TABLE `trongtaitrandau` DISABLE KEYS */;
INSERT INTO `trongtaitrandau` VALUES (3,17,1,'TRONG_TAI_CHINH',1,'2026-05-20 19:46:32'),(4,17,2,'GIAM_SAT',1,'2026-05-20 19:46:47');
/*!40000 ALTER TABLE `trongtaitrandau` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `v_dieukien_giai_thanhtich`
--

DROP TABLE IF EXISTS `v_dieukien_giai_thanhtich`;
/*!50001 DROP VIEW IF EXISTS `v_dieukien_giai_thanhtich`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_dieukien_giai_thanhtich` AS SELECT 
 1 AS `iddieukienthamgia`,
 1 AS `idgiaidau`,
 1 AS `thanh_tich_duoc_phep`,
 1 AS `hang_tot_nhat`,
 1 AS `hang_toi_da_duoc_phep`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `vandongvien`
--

DROP TABLE IF EXISTS `vandongvien`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vandongvien` (
  `idvandongvien` int(11) NOT NULL AUTO_INCREMENT,
  `idnguoidung` int(11) NOT NULL,
  `mavandongvien` varchar(100) NOT NULL,
  `chieucao` decimal(5,2) DEFAULT NULL,
  `cannang` decimal(5,2) DEFAULT NULL,
  `vitri` varchar(100) NOT NULL,
  `trangthaidaugiai` varchar(50) NOT NULL DEFAULT 'CHO_XAC_NHAN',
  PRIMARY KEY (`idvandongvien`),
  UNIQUE KEY `idnguoidung` (`idnguoidung`),
  UNIQUE KEY `mavandongvien` (`mavandongvien`),
  CONSTRAINT `fk_vdv_nguoidung` FOREIGN KEY (`idnguoidung`) REFERENCES `nguoidung` (`idnguoidung`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_vdv_chieucao` CHECK (`chieucao` is null or `chieucao` > 0),
  CONSTRAINT `chk_vdv_cannang` CHECK (`cannang` is null or `cannang` > 0),
  CONSTRAINT `chk_vdv_vitri` CHECK (`vitri` in ('CHU_CONG','PHU_CONG','CHUYEN_HAI','DOI_CHUYEN','LIBERO','DOI_TRU')),
  CONSTRAINT `chk_vdv_trangthai` CHECK (`trangthaidaugiai` in ('DU_DIEU_KIEN','CHO_XAC_NHAN','BI_HUY_TU_CACH','DANG_NGHI_PHEP'))
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vandongvien`
--

LOCK TABLES `vandongvien` WRITE;
/*!40000 ALTER TABLE `vandongvien` DISABLE KEYS */;
INSERT INTO `vandongvien` VALUES (1,12,'VDV001',180.00,72.00,'CHU_CONG','DU_DIEU_KIEN'),(2,13,'VDV002',170.00,60.00,'LIBERO','DU_DIEU_KIEN'),(3,14,'VDV003',182.00,74.00,'PHU_CONG','DU_DIEU_KIEN'),(4,15,'VDV004',185.00,78.00,'CHUYEN_HAI','DU_DIEU_KIEN'),(5,16,'VDV005',176.00,65.00,'DOI_CHUYEN','DU_DIEU_KIEN'),(6,17,'VDV006',181.00,70.00,'CHU_CONG','DU_DIEU_KIEN'),(7,18,'VDV007',179.00,68.00,'PHU_CONG','DU_DIEU_KIEN'),(8,19,'VDV008',168.00,58.00,'LIBERO','DU_DIEU_KIEN'),(11,113,'VDV2026051814094470',NULL,NULL,'CHU_CONG','DU_DIEU_KIEN'),(12,114,'VDV2026051814103152',NULL,NULL,'PHU_CONG','DU_DIEU_KIEN'),(13,115,'VDV2026051814105220',NULL,NULL,'CHUYEN_HAI','DU_DIEU_KIEN'),(14,116,'VDV2026051814110625',NULL,NULL,'DOI_CHUYEN','DU_DIEU_KIEN'),(15,117,'VDV2026051814112154',NULL,NULL,'LIBERO','DU_DIEU_KIEN'),(16,118,'VDV2026051814113635',NULL,NULL,'DOI_TRU','DU_DIEU_KIEN'),(17,119,'VDV2026051913152714',NULL,NULL,'CHU_CONG','DU_DIEU_KIEN'),(18,120,'VDV2026051913162996',NULL,NULL,'PHU_CONG','DU_DIEU_KIEN'),(19,121,'VDV2026051913164653',NULL,NULL,'CHUYEN_HAI','DU_DIEU_KIEN'),(20,122,'VDV2026051913165974',NULL,NULL,'DOI_CHUYEN','DU_DIEU_KIEN'),(21,123,'VDV2026051913171133',NULL,NULL,'LIBERO','DU_DIEU_KIEN'),(22,124,'VDV2026051913172347',NULL,NULL,'DOI_TRU','DU_DIEU_KIEN');
/*!40000 ALTER TABLE `vandongvien` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vitrithidau`
--

DROP TABLE IF EXISTS `vitrithidau`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vitrithidau` (
  `idvitrithidau` int(11) NOT NULL AUTO_INCREMENT,
  `tenvitrithidau` varchar(300) NOT NULL,
  `loaihinh` varchar(50) NOT NULL DEFAULT 'NHA_THI_DAU',
  `idkhuvuc` int(11) NOT NULL,
  `diachi` varchar(500) NOT NULL,
  `diachi_chitiet` varchar(1000) DEFAULT NULL,
  `succhua` int(11) NOT NULL DEFAULT 0,
  `kinhdo` decimal(10,7) DEFAULT NULL,
  `vido` decimal(10,7) DEFAULT NULL,
  `sdt_lienhe` varchar(30) DEFAULT NULL,
  `nguoi_lienhe` varchar(200) DEFAULT NULL,
  `email_lienhe` varchar(200) DEFAULT NULL,
  `mota` varchar(1000) DEFAULT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'HOAT_DONG',
  `ngaytao` datetime NOT NULL DEFAULT current_timestamp(),
  `ngaycapnhat` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`idvitrithidau`),
  UNIQUE KEY `uq_vitri_ten_diachi` (`tenvitrithidau`,`diachi`) USING HASH,
  KEY `idx_vitri_khuvuc_trangthai` (`idkhuvuc`,`trangthai`),
  KEY `idx_vitri_loaihinh_trangthai` (`loaihinh`,`trangthai`),
  CONSTRAINT `fk_vitri_khuvuc` FOREIGN KEY (`idkhuvuc`) REFERENCES `khuvuc` (`idkhuvuc`) ON UPDATE CASCADE,
  CONSTRAINT `chk_vitri_trangthai` CHECK (`trangthai` in ('HOAT_DONG','DANG_BAO_TRI','NGUNG_SU_DUNG'))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vitrithidau`
--

LOCK TABLES `vitrithidau` WRITE;
/*!40000 ALTER TABLE `vitrithidau` DISABLE KEYS */;
INSERT INTO `vitrithidau` VALUES (3,'Sân vận động Quốc gia Mỹ Đình','SAN_VAN_DONG',1028,'Số 1 Lê Đức Thọ, phường Mỹ Đình 1, quận Nam Từ Liêm, Hà Nội','Số 1 Lê Đức Thọ, phường Mỹ Đình 1, quận Nam Từ Liêm, Hà Nội, Việt Nam',40000,105.7649000,21.0206000,NULL,NULL,NULL,'Địa điểm thi đấu lớn tại Hà Nội, dùng làm dữ liệu mẫu cho VTMS.','HOAT_DONG','2026-05-19 22:45:18',NULL),(4,'Nhà thi đấu Cầu Giấy','NHA_THI_DAU',1030,'Phường Dịch Vọng, quận Cầu Giấy, Hà Nội','Phường Dịch Vọng, quận Cầu Giấy, Hà Nội, Việt Nam',3000,NULL,NULL,NULL,NULL,NULL,'Địa điểm thi đấu mẫu tại khu vực Cầu Giấy.','HOAT_DONG','2026-05-19 22:45:18',NULL),(5,'Nhà thi đấu Tây Hồ','NHA_THI_DAU',1032,'Phường Xuân La, quận Tây Hồ, Hà Nội','Phường Xuân La, quận Tây Hồ, Hà Nội, Việt Nam',2500,NULL,NULL,NULL,NULL,NULL,'Địa điểm thi đấu mẫu tại khu vực Tây Hồ.','HOAT_DONG','2026-05-19 22:45:18',NULL);
/*!40000 ALTER TABLE `vitrithidau` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_vitrithidau_bi_strict
BEFORE INSERT ON vitrithidau
FOR EACH ROW
BEGIN
    DECLARE v_cap VARCHAR(50);
    DECLARE v_trangthai_kv VARCHAR(50);

    IF NEW.loaihinh NOT IN ('NHA_THI_DAU','SAN_VAN_DONG','TRUNG_TAM_THE_THAO','TRUONG_HOC','CONG_TY','CLB','KHAC') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loại hình vị trí thi đấu không hợp lệ.';
    END IF;

    IF NEW.succhua < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sức chứa vị trí thi đấu không được âm.';
    END IF;

    IF NEW.vido IS NOT NULL AND (NEW.vido < -90 OR NEW.vido > 90) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vĩ độ không hợp lệ.';
    END IF;

    IF NEW.kinhdo IS NOT NULL AND (NEW.kinhdo < -180 OR NEW.kinhdo > 180) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Kinh độ không hợp lệ.';
    END IF;

    IF NEW.email_lienhe IS NOT NULL AND NEW.email_lienhe NOT LIKE '%_@_%._%' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email liên hệ không hợp lệ.';
    END IF;

    SELECT capkhuvuc, trangthai INTO v_cap, v_trangthai_kv
    FROM khuvuc
    WHERE idkhuvuc = NEW.idkhuvuc;

    IF v_trangthai_kv <> 'HOAT_DONG' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không thể tạo vị trí thi đấu trong khu vực ngừng sử dụng.';
    END IF;

    IF v_cap = 'QUOC_GIA' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vị trí thi đấu phải gắn với khu vực cụ thể hơn cấp quốc gia.';
    END IF;

    IF NEW.diachi_chitiet IS NULL THEN
        SET NEW.diachi_chitiet = NEW.diachi;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_vitrithidau_bu_strict
BEFORE UPDATE ON vitrithidau
FOR EACH ROW
BEGIN
    DECLARE v_cap VARCHAR(50);
    DECLARE v_trangthai_kv VARCHAR(50);

    IF NEW.loaihinh NOT IN ('NHA_THI_DAU','SAN_VAN_DONG','TRUNG_TAM_THE_THAO','TRUONG_HOC','CONG_TY','CLB','KHAC') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loại hình vị trí thi đấu không hợp lệ.';
    END IF;

    IF NEW.succhua < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sức chứa vị trí thi đấu không được âm.';
    END IF;

    IF NEW.vido IS NOT NULL AND (NEW.vido < -90 OR NEW.vido > 90) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vĩ độ không hợp lệ.';
    END IF;

    IF NEW.kinhdo IS NOT NULL AND (NEW.kinhdo < -180 OR NEW.kinhdo > 180) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Kinh độ không hợp lệ.';
    END IF;

    IF NEW.email_lienhe IS NOT NULL AND NEW.email_lienhe NOT LIKE '%_@_%._%' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email liên hệ không hợp lệ.';
    END IF;

    SELECT capkhuvuc, trangthai INTO v_cap, v_trangthai_kv
    FROM khuvuc
    WHERE idkhuvuc = NEW.idkhuvuc;

    IF v_trangthai_kv <> 'HOAT_DONG' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không thể gắn vị trí thi đấu với khu vực ngừng sử dụng.';
    END IF;

    IF v_cap = 'QUOC_GIA' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vị trí thi đấu phải gắn với khu vực cụ thể hơn cấp quốc gia.';
    END IF;

    IF NEW.diachi_chitiet IS NULL THEN
        SET NEW.diachi_chitiet = NEW.diachi;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `vongdau`
--

DROP TABLE IF EXISTS `vongdau`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vongdau` (
  `idvongdau` int(11) NOT NULL AUTO_INCREMENT,
  `idgiaidau` int(11) NOT NULL,
  `tenvongdau` varchar(300) NOT NULL,
  `loaivongdau` varchar(50) NOT NULL,
  `thutu` int(11) NOT NULL,
  `thoigianbatdau` date DEFAULT NULL,
  `thoigianketthuc` date DEFAULT NULL,
  `so_doi_tham_gia` int(11) NOT NULL,
  `co_bangdau` tinyint(1) NOT NULL DEFAULT 0,
  `so_bang_dau` int(11) DEFAULT NULL,
  `so_doi_moi_bang_du_kien` int(11) DEFAULT NULL,
  `so_luot_dau` int(11) NOT NULL DEFAULT 1,
  `so_doi_vao_vong_sau` int(11) DEFAULT NULL,
  `so_doi_vao_moi_bang` int(11) DEFAULT NULL,
  `cach_chon_doi_di_tiep` varchar(100) NOT NULL DEFAULT 'KHONG_AP_DUNG',
  `cach_xep_cap_dau` varchar(50) NOT NULL DEFAULT 'KHONG_AP_DUNG',
  `cach_phan_bo_bang` varchar(50) NOT NULL DEFAULT 'MANUAL',
  `cho_phep_bang_le` tinyint(1) NOT NULL DEFAULT 0,
  `chenh_lech_toi_da` int(11) NOT NULL DEFAULT 1,
  `tieu_chi_so_sanh_bang_le` varchar(50) NOT NULL DEFAULT 'DIEM_TRUNG_BINH',
  `seed_source` varchar(100) NOT NULL DEFAULT 'KHONG_AP_DUNG',
  `co_tranh_hang_ba` tinyint(1) NOT NULL DEFAULT 0,
  `trangthai` varchar(50) NOT NULL DEFAULT 'NHAP',
  `ngaytao` datetime NOT NULL DEFAULT current_timestamp(),
  `ngaycapnhat` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`idvongdau`),
  UNIQUE KEY `uq_vongdau_thutu` (`idgiaidau`,`thutu`),
  KEY `idx_vongdau_giai_thutu_trangthai` (`idgiaidau`,`thutu`,`trangthai`),
  CONSTRAINT `fk_vongdau_giaidau` FOREIGN KEY (`idgiaidau`) REFERENCES `giaidau` (`idgiaidau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_vongdau_loai` CHECK (`loaivongdau` in ('VONG_DIEM','VONG_LOAI','CHUNG_KET','TRANH_HANG_BA')),
  CONSTRAINT `chk_vongdau_thutu` CHECK (`thutu` > 0),
  CONSTRAINT `chk_vongdau_sodoi` CHECK (`so_doi_tham_gia` >= 2),
  CONSTRAINT `chk_vongdau_bang` CHECK (`co_bangdau` = 0 and (`so_bang_dau` is null or `so_bang_dau` = 0) or `co_bangdau` = 1 and `so_bang_dau` is not null and `so_bang_dau` > 0),
  CONSTRAINT `chk_vongdau_luot` CHECK (`so_luot_dau` in (1,2)),
  CONSTRAINT `chk_vongdau_chondoi` CHECK (`cach_chon_doi_di_tiep` in ('TOP_N','TOP_N_MOI_BANG','THANG_DI_TIEP','BTC_CHON','KHONG_AP_DUNG')),
  CONSTRAINT `chk_vongdau_cachxep` CHECK (`cach_xep_cap_dau` in ('RANDOM','SEEDED','POT_DRAW','MANUAL','HYBRID','KHONG_AP_DUNG')),
  CONSTRAINT `chk_vongdau_seed` CHECK (`seed_source` in ('BANG_XEP_HANG_TRUOC','THU_HANG_VONG_TRUOC','DIEM_TICH_LUY','BTC_NHAP_TAY','KHONG_AP_DUNG')),
  CONSTRAINT `chk_vongdau_trangthai` CHECK (`trangthai` in ('NHAP','DA_TAO_DOI','CHO_PHAN_CONG_BANG','DA_TAO_BANG','DA_TAO_TRAN','DA_CONG_BO_LICH','DANG_DIEN_RA','DA_HOAN_THANH','DA_KET_THUC','DA_HUY')),
  CONSTRAINT `chk_vongdau_ngay` CHECK (`thoigianbatdau` is null or `thoigianketthuc` is null or `thoigianketthuc` >= `thoigianbatdau`),
  CONSTRAINT `chk_vongdau_bang_le` CHECK (`chenh_lech_toi_da` >= 0 and `tieu_chi_so_sanh_bang_le` in ('TONG_DIEM','DIEM_TRUNG_BINH','TY_LE_SET','TY_LE_DIEM')),
  CONSTRAINT `chk_vongdau_phan_bo_bang` CHECK (`cach_phan_bo_bang` in ('RANDOM','SEEDED','POT_DRAW','MANUAL','HYBRID'))
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vongdau`
--

LOCK TABLES `vongdau` WRITE;
/*!40000 ALTER TABLE `vongdau` DISABLE KEYS */;
INSERT INTO `vongdau` VALUES (5,105,'Vòng loại trực tiếp','VONG_LOAI',1,NULL,NULL,4,0,0,NULL,1,NULL,NULL,'THANG_DI_TIEP','HYBRID','MANUAL',0,1,'DIEM_TRUNG_BINH','BTC_NHAP_TAY',1,'NHAP','2026-05-19 00:32:32',NULL),(7,106,'Vòng loại trực tiếp','VONG_LOAI',1,NULL,NULL,2,0,0,NULL,1,NULL,NULL,'THANG_DI_TIEP','HYBRID','MANUAL',0,1,'DIEM_TRUNG_BINH','BTC_NHAP_TAY',1,'NHAP','2026-05-19 21:34:36','2026-05-19 22:46:39');
/*!40000 ALTER TABLE `vongdau` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_vongdau_bi
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Temporary view structure for view `vw_cautruc_giaidau`
--

DROP TABLE IF EXISTS `vw_cautruc_giaidau`;
/*!50001 DROP VIEW IF EXISTS `vw_cautruc_giaidau`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_cautruc_giaidau` AS SELECT 
 1 AS `idgiaidau`,
 1 AS `tengiaidau`,
 1 AS `macapgiaidau`,
 1 AS `khuvucphamvi`,
 1 AS `idvongdau`,
 1 AS `tenvongdau`,
 1 AS `loaivongdau`,
 1 AS `thutu`,
 1 AS `co_bangdau`,
 1 AS `so_bang_dau`,
 1 AS `so_doi_tham_gia`,
 1 AS `so_doi_vao_vong_sau`,
 1 AS `trangthai_vong`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_dieu_kien_tham_gia_giai`
--

DROP TABLE IF EXISTS `vw_dieu_kien_tham_gia_giai`;
/*!50001 DROP VIEW IF EXISTS `vw_dieu_kien_tham_gia_giai`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_dieu_kien_tham_gia_giai` AS SELECT 
 1 AS `iddieukienthamgia`,
 1 AS `idgiaidau`,
 1 AS `tengiaidau`,
 1 AS `ten_dieukien`,
 1 AS `capdoituongthamgia`,
 1 AS `yeu_cau_thanh_tich`,
 1 AS `capgiaidau_thanh_tich_nguon`,
 1 AS `hang_toi_thieu_duoc_phep`,
 1 AS `so_mua_giai_gan_nhat_duoc_tinh`,
 1 AS `cho_phep_btc_duyet_ngoai_le`,
 1 AS `trangthai`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_doi_du_dieu_kien_tham_gia`
--

DROP TABLE IF EXISTS `vw_doi_du_dieu_kien_tham_gia`;
/*!50001 DROP VIEW IF EXISTS `vw_doi_du_dieu_kien_tham_gia`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_doi_du_dieu_kien_tham_gia` AS SELECT 
 1 AS `iddieukien`,
 1 AS `idgiaidau`,
 1 AS `tengiaidau`,
 1 AS `iddoibong`,
 1 AS `tendoibong`,
 1 AS `khuvuc_daidien`,
 1 AS `cap_daidien`,
 1 AS `nguon_dieukien`,
 1 AS `lydo_dieukien`,
 1 AS `trangthai`,
 1 AS `idthanhtich`,
 1 AS `hang_dat_duoc`,
 1 AS `danhhieu`,
 1 AS `mua_giai`,
 1 AS `idsuat`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_goi_y_doi_du_dieu_kien_theo_thanh_tich`
--

DROP TABLE IF EXISTS `vw_goi_y_doi_du_dieu_kien_theo_thanh_tich`;
/*!50001 DROP VIEW IF EXISTS `vw_goi_y_doi_du_dieu_kien_theo_thanh_tich`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_goi_y_doi_du_dieu_kien_theo_thanh_tich` AS SELECT 
 1 AS `iddieukienthamgia`,
 1 AS `idgiaidau_dich`,
 1 AS `tengiaidau_dich`,
 1 AS `iddoibong`,
 1 AS `tendoibong`,
 1 AS `idthanhtich`,
 1 AS `giai_dat_thanh_tich`,
 1 AS `hang_dat_duoc`,
 1 AS `danhhieu`,
 1 AS `mua_giai`,
 1 AS `yeu_cau_thanh_tich`,
 1 AS `hang_toi_thieu_duoc_phep`,
 1 AS `khuvuc_daidien`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_public_bangxephang`
--

DROP TABLE IF EXISTS `vw_public_bangxephang`;
/*!50001 DROP VIEW IF EXISTS `vw_public_bangxephang`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_public_bangxephang` AS SELECT 
 1 AS `idbangxephang`,
 1 AS `tengiaidau`,
 1 AS `tenbangxephang`,
 1 AS `phamvi`,
 1 AS `hang`,
 1 AS `tendoibong`,
 1 AS `sotran`,
 1 AS `thang`,
 1 AS `thua`,
 1 AS `sosetthang`,
 1 AS `sosetthua`,
 1 AS `diem`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_public_ketqua`
--

DROP TABLE IF EXISTS `vw_public_ketqua`;
/*!50001 DROP VIEW IF EXISTS `vw_public_ketqua`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_public_ketqua` AS SELECT 
 1 AS `idketqua`,
 1 AS `tengiaidau`,
 1 AS `ma_tran`,
 1 AS `ten_tran`,
 1 AS `doi1`,
 1 AS `doi2`,
 1 AS `doithang`,
 1 AS `sosetdoi1`,
 1 AS `sosetdoi2`,
 1 AS `diemdoi1`,
 1 AS `diemdoi2`,
 1 AS `trangthai`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_public_lichthidau`
--

DROP TABLE IF EXISTS `vw_public_lichthidau`;
/*!50001 DROP VIEW IF EXISTS `vw_public_lichthidau`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_public_lichthidau` AS SELECT 
 1 AS `idtrandau`,
 1 AS `tengiaidau`,
 1 AS `tenvongdau`,
 1 AS `tenbang`,
 1 AS `ma_tran`,
 1 AS `ten_tran`,
 1 AS `doi1`,
 1 AS `doi2`,
 1 AS `tenvitrithidau`,
 1 AS `tensandau`,
 1 AS `thoigianbatdau`,
 1 AS `trangthai`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_sandau_daydu_khuvuc`
--

DROP TABLE IF EXISTS `vw_sandau_daydu_khuvuc`;
/*!50001 DROP VIEW IF EXISTS `vw_sandau_daydu_khuvuc`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_sandau_daydu_khuvuc` AS SELECT 
 1 AS `idsandau`,
 1 AS `tensandau`,
 1 AS `loaisan`,
 1 AS `mat_san`,
 1 AS `kichthuoc`,
 1 AS `succhua_san`,
 1 AS `mota_san`,
 1 AS `trangthai_san`,
 1 AS `ngaytao_san`,
 1 AS `ngaycapnhat_san`,
 1 AS `idvitrithidau`,
 1 AS `tenvitrithidau`,
 1 AS `loaihinh_vitrithidau`,
 1 AS `idkhuvuc_gan_truc_tiep`,
 1 AS `makhuvuc_gan_truc_tiep`,
 1 AS `tenkhuvuc_gan_truc_tiep`,
 1 AS `capkhuvuc_gan_truc_tiep`,
 1 AS `id_quocgia`,
 1 AS `ten_quocgia`,
 1 AS `id_tinhthanh`,
 1 AS `ten_tinhthanh`,
 1 AS `id_quanhuyen`,
 1 AS `ten_quanhuyen`,
 1 AS `id_xaphuong`,
 1 AS `ten_xaphuong`,
 1 AS `id_donvi`,
 1 AS `ten_donvi`,
 1 AS `duong_dan_khuvuc`,
 1 AS `diachi`,
 1 AS `diachi_chitiet`,
 1 AS `succhua_vitrithidau`,
 1 AS `kinhdo`,
 1 AS `vido`,
 1 AS `trangthai_vitrithidau`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_thanhtich_doibong`
--

DROP TABLE IF EXISTS `vw_thanhtich_doibong`;
/*!50001 DROP VIEW IF EXISTS `vw_thanhtich_doibong`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_thanhtich_doibong` AS SELECT 
 1 AS `idthanhtich`,
 1 AS `iddoibong`,
 1 AS `tendoibong`,
 1 AS `idgiaidau`,
 1 AS `tengiaidau`,
 1 AS `macapgiaidau`,
 1 AS `tencapgiaidau`,
 1 AS `tenkhuvuc`,
 1 AS `mua_giai`,
 1 AS `hang_dat_duoc`,
 1 AS `danhhieu`,
 1 AS `nguon_ghi_nhan`,
 1 AS `ngay_cong_nhan`,
 1 AS `trangthai`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_vitrithidau_daydu_khuvuc`
--

DROP TABLE IF EXISTS `vw_vitrithidau_daydu_khuvuc`;
/*!50001 DROP VIEW IF EXISTS `vw_vitrithidau_daydu_khuvuc`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_vitrithidau_daydu_khuvuc` AS SELECT 
 1 AS `idvitrithidau`,
 1 AS `tenvitrithidau`,
 1 AS `loaihinh`,
 1 AS `idkhuvuc_gan_truc_tiep`,
 1 AS `makhuvuc_gan_truc_tiep`,
 1 AS `tenkhuvuc_gan_truc_tiep`,
 1 AS `capkhuvuc_gan_truc_tiep`,
 1 AS `id_quocgia`,
 1 AS `ten_quocgia`,
 1 AS `id_tinhthanh`,
 1 AS `ten_tinhthanh`,
 1 AS `id_quanhuyen`,
 1 AS `ten_quanhuyen`,
 1 AS `id_xaphuong`,
 1 AS `ten_xaphuong`,
 1 AS `id_donvi`,
 1 AS `ten_donvi`,
 1 AS `duong_dan_khuvuc`,
 1 AS `diachi`,
 1 AS `diachi_chitiet`,
 1 AS `succhua`,
 1 AS `kinhdo`,
 1 AS `vido`,
 1 AS `sdt_lienhe`,
 1 AS `nguoi_lienhe`,
 1 AS `email_lienhe`,
 1 AS `mota`,
 1 AS `trangthai`,
 1 AS `ngaytao`,
 1 AS `ngaycapnhat`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `yeucaucapnhathoso`
--

DROP TABLE IF EXISTS `yeucaucapnhathoso`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `yeucaucapnhathoso` (
  `idyeucaucapnhat` int(11) NOT NULL AUTO_INCREMENT,
  `idnguoidung` int(11) NOT NULL,
  `banglienquan` varchar(100) NOT NULL,
  `truongcapnhat` varchar(100) NOT NULL,
  `giatricu` varchar(1000) DEFAULT NULL,
  `giatrimoi` varchar(1000) NOT NULL,
  `lydo` varchar(1000) DEFAULT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'CHO_DUYET',
  `ngaygui` datetime NOT NULL DEFAULT current_timestamp(),
  `ngayxuly` datetime DEFAULT NULL,
  PRIMARY KEY (`idyeucaucapnhat`),
  KEY `fk_yccnhs_nguoidung` (`idnguoidung`),
  CONSTRAINT `fk_yccnhs_nguoidung` FOREIGN KEY (`idnguoidung`) REFERENCES `nguoidung` (`idnguoidung`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_yccnhs_trangthai` CHECK (`trangthai` in ('CHO_DUYET','DA_DUYET','TU_CHOI')),
  CONSTRAINT `chk_yccnhs_ngayxuly` CHECK (`ngayxuly` is null or `ngayxuly` >= `ngaygui`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `yeucaucapnhathoso`
--

LOCK TABLES `yeucaucapnhathoso` WRITE;
/*!40000 ALTER TABLE `yeucaucapnhathoso` DISABLE KEYS */;
/*!40000 ALTER TABLE `yeucaucapnhathoso` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `yeucauxacnhan`
--

DROP TABLE IF EXISTS `yeucauxacnhan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `yeucauxacnhan` (
  `idyeucau` int(11) NOT NULL AUTO_INCREMENT,
  `loainguoigui` varchar(100) NOT NULL,
  `idnguoigui` int(11) NOT NULL,
  `loainguoinhan` varchar(100) NOT NULL,
  `idnguoinhan` int(11) NOT NULL,
  `loaixacnhan` varchar(100) NOT NULL,
  `noidung` varchar(1000) NOT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'CHO_DUYET',
  `ngaygui` datetime NOT NULL DEFAULT current_timestamp(),
  `ngayxuly` datetime DEFAULT NULL,
  `ghichu` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`idyeucau`),
  CONSTRAINT `chk_ycxn_loaixacnhan` CHECK (`loaixacnhan` in ('XAC_NHAN_HLV','XAC_NHAN_VDV','XAC_NHAN_THAY_DOI_HO_SO','XAC_NHAN_NGHI_PHEP','XAC_NHAN_TAI_KHOAN_TRONG_TAI','XAC_NHAN_DANG_KY_GIAI')),
  CONSTRAINT `chk_ycxn_trangthai` CHECK (`trangthai` in ('CHO_DUYET','DA_DUYET','TU_CHOI','DA_HUY')),
  CONSTRAINT `chk_ycxn_ngayxuly` CHECK (`ngayxuly` is null or `ngayxuly` >= `ngaygui`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `yeucauxacnhan`
--

LOCK TABLES `yeucauxacnhan` WRITE;
/*!40000 ALTER TABLE `yeucauxacnhan` DISABLE KEYS */;
INSERT INTO `yeucauxacnhan` VALUES (7,'HUAN_LUYEN_VIEN',10,'BAN_TO_CHUC',2,'XAC_NHAN_HLV','Ước mơ làm phi hành gia','DA_DUYET','2026-05-18 13:23:36','2026-05-18 13:24:39','Xac nhan tu cach huan luyen vien'),(8,'HUAN_LUYEN_VIEN',11,'BAN_TO_CHUC',2,'XAC_NHAN_HLV','HLV chưa có kinh nghiệm, đang fake kinh nghiệm','DA_DUYET','2026-05-18 13:26:33','2026-05-18 13:26:54','Xac nhan tu cach huan luyen vien'),(10,'HUAN_LUYEN_VIEN',10,'BAN_TO_CHUC',1,'XAC_NHAN_DANG_KY_GIAI','Dang ky giai dau #106, doi #18. Yeu cau xac nhan doi Đội super Men tham gia giai dau Giải quốc gia VN 2026','DA_DUYET','2026-05-19 21:07:44','2026-05-19 21:08:37','Duyet dang ky doi bong'),(11,'HUAN_LUYEN_VIEN',11,'BAN_TO_CHUC',1,'XAC_NHAN_DANG_KY_GIAI','Dang ky giai dau #106, doi #19. Yeu cau xac nhan doi Đội bóng Thủ đô tham gia giai dau Giải quốc gia VN 2026','DA_DUYET','2026-05-19 21:08:29','2026-05-19 21:08:36','Duyet dang ky doi bong');
/*!40000 ALTER TABLE `yeucauxacnhan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'vtms'
--

--
-- Dumping routines for database 'vtms'
--
/*!50003 DROP FUNCTION IF EXISTS `fn_khuvuc_la_con` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_khuvuc_la_con`(p_child INT, p_parent INT) RETURNS tinyint(4)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_cap_nhat_slot_tu_ketqua` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cap_nhat_slot_tu_ketqua`(IN p_idtrandau INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tao_doi_du_dieu_kien_tu_thanhtich` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tao_doi_du_dieu_kien_tu_thanhtich`(IN p_idgiaidau INT)
BEGIN
    CALL sp_tao_doi_du_dieu_kien_tu_thanhtich_v2(p_idgiaidau);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_tao_doi_du_dieu_kien_tu_thanhtich_v2` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_tao_doi_du_dieu_kien_tu_thanhtich_v2`(IN p_idgiaidau INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_vtms5_add_column_if_not_exists` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_vtms5_add_column_if_not_exists`(
    IN p_table_name VARCHAR(128),
    IN p_column_name VARCHAR(128),
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
        SET @vtms5_sql = CONCAT('ALTER TABLE `', p_table_name, '` ADD COLUMN ', p_column_definition);
        PREPARE vtms5_stmt FROM @vtms5_sql;
        EXECUTE vtms5_stmt;
        DEALLOCATE PREPARE vtms5_stmt;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_vtms5_add_index_if_not_exists` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_vtms5_add_index_if_not_exists`(
    IN p_table_name VARCHAR(128),
    IN p_index_name VARCHAR(128),
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
        SET @vtms5_sql = p_index_definition;
        PREPARE vtms5_stmt FROM @vtms5_sql;
        EXECUTE vtms5_stmt;
        DEALLOCATE PREPARE vtms5_stmt;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `v_dieukien_giai_thanhtich`
--

/*!50001 DROP VIEW IF EXISTS `v_dieukien_giai_thanhtich`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_dieukien_giai_thanhtich` AS select `d`.`iddieukienthamgia` AS `iddieukienthamgia`,`d`.`idgiaidau` AS `idgiaidau`,group_concat(`t`.`ma_thanhtich` order by `t`.`hang_tuong_ung` ASC,`t`.`ma_thanhtich` ASC separator ',') AS `thanh_tich_duoc_phep`,min(`t`.`hang_tuong_ung`) AS `hang_tot_nhat`,max(`t`.`hang_tuong_ung`) AS `hang_toi_da_duoc_phep` from (`dieukienthamgiagiai` `d` left join `dieukienthamgiagiai_thanhtich` `t` on(`t`.`iddieukienthamgia` = `d`.`iddieukienthamgia` and `t`.`trangthai` = 'HOAT_DONG')) group by `d`.`iddieukienthamgia`,`d`.`idgiaidau` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_cautruc_giaidau`
--

/*!50001 DROP VIEW IF EXISTS `vw_cautruc_giaidau`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_cautruc_giaidau` AS select `gd`.`idgiaidau` AS `idgiaidau`,`gd`.`tengiaidau` AS `tengiaidau`,`cg`.`macapgiaidau` AS `macapgiaidau`,`kv`.`tenkhuvuc` AS `khuvucphamvi`,`vd`.`idvongdau` AS `idvongdau`,`vd`.`tenvongdau` AS `tenvongdau`,`vd`.`loaivongdau` AS `loaivongdau`,`vd`.`thutu` AS `thutu`,`vd`.`co_bangdau` AS `co_bangdau`,`vd`.`so_bang_dau` AS `so_bang_dau`,`vd`.`so_doi_tham_gia` AS `so_doi_tham_gia`,`vd`.`so_doi_vao_vong_sau` AS `so_doi_vao_vong_sau`,`vd`.`trangthai` AS `trangthai_vong` from (((`giaidau` `gd` join `capgiaidau` `cg` on(`cg`.`idcapgiaidau` = `gd`.`idcapgiaidau`)) join `khuvuc` `kv` on(`kv`.`idkhuvuc` = `gd`.`idkhuvucphamvi`)) left join `vongdau` `vd` on(`vd`.`idgiaidau` = `gd`.`idgiaidau`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_dieu_kien_tham_gia_giai`
--

/*!50001 DROP VIEW IF EXISTS `vw_dieu_kien_tham_gia_giai`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_dieu_kien_tham_gia_giai` AS select `dk`.`iddieukienthamgia` AS `iddieukienthamgia`,`dk`.`idgiaidau` AS `idgiaidau`,`gd`.`tengiaidau` AS `tengiaidau`,`dk`.`ten_dieukien` AS `ten_dieukien`,`dk`.`capdoituongthamgia` AS `capdoituongthamgia`,`dk`.`yeu_cau_thanh_tich` AS `yeu_cau_thanh_tich`,`cgn`.`macapgiaidau` AS `capgiaidau_thanh_tich_nguon`,`dk`.`hang_toi_thieu_duoc_phep` AS `hang_toi_thieu_duoc_phep`,`dk`.`so_mua_giai_gan_nhat_duoc_tinh` AS `so_mua_giai_gan_nhat_duoc_tinh`,`dk`.`cho_phep_btc_duyet_ngoai_le` AS `cho_phep_btc_duyet_ngoai_le`,`dk`.`trangthai` AS `trangthai` from ((`dieukienthamgiagiai` `dk` join `giaidau` `gd` on(`gd`.`idgiaidau` = `dk`.`idgiaidau`)) left join `capgiaidau` `cgn` on(`cgn`.`idcapgiaidau` = `dk`.`idcapgiaidau_thanh_tich_nguon`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_doi_du_dieu_kien_tham_gia`
--

/*!50001 DROP VIEW IF EXISTS `vw_doi_du_dieu_kien_tham_gia`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_doi_du_dieu_kien_tham_gia` AS select `ddk`.`iddieukien` AS `iddieukien`,`ddk`.`idgiaidau` AS `idgiaidau`,`gd`.`tengiaidau` AS `tengiaidau`,`ddk`.`iddoibong` AS `iddoibong`,`db`.`tendoibong` AS `tendoibong`,`kv`.`tenkhuvuc` AS `khuvuc_daidien`,`kv`.`capkhuvuc` AS `cap_daidien`,`ddk`.`nguon_dieukien` AS `nguon_dieukien`,`ddk`.`lydo_dieukien` AS `lydo_dieukien`,`ddk`.`trangthai` AS `trangthai`,`ddk`.`idthanhtich` AS `idthanhtich`,`tt`.`hang_dat_duoc` AS `hang_dat_duoc`,`tt`.`danhhieu` AS `danhhieu`,`tt`.`mua_giai` AS `mua_giai`,`ddk`.`idsuat` AS `idsuat` from ((((`doidudieukienthamgia` `ddk` join `giaidau` `gd` on(`gd`.`idgiaidau` = `ddk`.`idgiaidau`)) join `doibong` `db` on(`db`.`iddoibong` = `ddk`.`iddoibong`)) join `khuvuc` `kv` on(`kv`.`idkhuvuc` = `db`.`idkhuvucdaidien`)) left join `thanhtichdoibong` `tt` on(`tt`.`idthanhtich` = `ddk`.`idthanhtich`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_goi_y_doi_du_dieu_kien_theo_thanh_tich`
--

/*!50001 DROP VIEW IF EXISTS `vw_goi_y_doi_du_dieu_kien_theo_thanh_tich`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_goi_y_doi_du_dieu_kien_theo_thanh_tich` AS select `dk`.`iddieukienthamgia` AS `iddieukienthamgia`,`dk`.`idgiaidau` AS `idgiaidau_dich`,`gdich`.`tengiaidau` AS `tengiaidau_dich`,`tt`.`iddoibong` AS `iddoibong`,`db`.`tendoibong` AS `tendoibong`,`tt`.`idthanhtich` AS `idthanhtich`,`gnguon`.`tengiaidau` AS `giai_dat_thanh_tich`,`tt`.`hang_dat_duoc` AS `hang_dat_duoc`,`tt`.`danhhieu` AS `danhhieu`,`tt`.`mua_giai` AS `mua_giai`,`dk`.`yeu_cau_thanh_tich` AS `yeu_cau_thanh_tich`,`dk`.`hang_toi_thieu_duoc_phep` AS `hang_toi_thieu_duoc_phep`,`kvdoi`.`tenkhuvuc` AS `khuvuc_daidien` from (((((`dieukienthamgiagiai` `dk` join `giaidau` `gdich` on(`gdich`.`idgiaidau` = `dk`.`idgiaidau`)) join `thanhtichdoibong` `tt` on(`tt`.`trangthai` = 'HOP_LE')) join `giaidau` `gnguon` on(`gnguon`.`idgiaidau` = `tt`.`idgiaidau`)) join `doibong` `db` on(`db`.`iddoibong` = `tt`.`iddoibong` and `db`.`trangthai` = 'HOAT_DONG')) join `khuvuc` `kvdoi` on(`kvdoi`.`idkhuvuc` = `db`.`idkhuvucdaidien`)) where `dk`.`trangthai` = 'HOAT_DONG' and `dk`.`yeu_cau_thanh_tich` in ('VO_DICH','A_QUAN','HANG_BA','TOP_N','THEO_XEP_HANG') and `kvdoi`.`capkhuvuc` = `dk`.`capdoituongthamgia` and `tt`.`idcapgiaidau` = `dk`.`idcapgiaidau_thanh_tich_nguon` and (`db`.`idkhuvucdaidien` = `gdich`.`idkhuvucphamvi` or `fn_khuvuc_la_con`(`db`.`idkhuvucdaidien`,`gdich`.`idkhuvucphamvi`) = 1) and (`dk`.`yeu_cau_thanh_tich` = 'VO_DICH' and `tt`.`hang_dat_duoc` = 1 or `dk`.`yeu_cau_thanh_tich` = 'A_QUAN' and `tt`.`hang_dat_duoc` = 2 or `dk`.`yeu_cau_thanh_tich` = 'HANG_BA' and `tt`.`hang_dat_duoc` = 3 or `dk`.`yeu_cau_thanh_tich` in ('TOP_N','THEO_XEP_HANG') and `tt`.`hang_dat_duoc` <= `dk`.`hang_toi_thieu_duoc_phep`) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_public_bangxephang`
--

/*!50001 DROP VIEW IF EXISTS `vw_public_bangxephang`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_public_bangxephang` AS select `bxh`.`idbangxephang` AS `idbangxephang`,`gd`.`tengiaidau` AS `tengiaidau`,`bxh`.`tenbangxephang` AS `tenbangxephang`,`bxh`.`phamvi` AS `phamvi`,`ct`.`hang` AS `hang`,`d`.`tendoibong` AS `tendoibong`,`ct`.`sotran` AS `sotran`,`ct`.`thang` AS `thang`,`ct`.`thua` AS `thua`,`ct`.`sosetthang` AS `sosetthang`,`ct`.`sosetthua` AS `sosetthua`,`ct`.`diem` AS `diem` from (((`bangxephang` `bxh` join `giaidau` `gd` on(`gd`.`idgiaidau` = `bxh`.`idgiaidau`)) join `chitietbangxephang` `ct` on(`ct`.`idbangxephang` = `bxh`.`idbangxephang`)) join `doibong` `d` on(`d`.`iddoibong` = `ct`.`iddoibong`)) where `bxh`.`trangthai` in ('DA_CONG_BO','DA_CAP_NHAT') */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_public_ketqua`
--

/*!50001 DROP VIEW IF EXISTS `vw_public_ketqua`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_public_ketqua` AS select `kq`.`idketqua` AS `idketqua`,`gd`.`tengiaidau` AS `tengiaidau`,`t`.`ma_tran` AS `ma_tran`,`t`.`ten_tran` AS `ten_tran`,`d1`.`tendoibong` AS `doi1`,`d2`.`tendoibong` AS `doi2`,`dt`.`tendoibong` AS `doithang`,`kq`.`sosetdoi1` AS `sosetdoi1`,`kq`.`sosetdoi2` AS `sosetdoi2`,`kq`.`diemdoi1` AS `diemdoi1`,`kq`.`diemdoi2` AS `diemdoi2`,`kq`.`trangthai` AS `trangthai` from (((((`ketquatrandau` `kq` join `trandau` `t` on(`t`.`idtrandau` = `kq`.`idtrandau`)) join `giaidau` `gd` on(`gd`.`idgiaidau` = `t`.`idgiaidau`)) left join `doibong` `d1` on(`d1`.`iddoibong` = `t`.`iddoibong1`)) left join `doibong` `d2` on(`d2`.`iddoibong` = `t`.`iddoibong2`)) left join `doibong` `dt` on(`dt`.`iddoibong` = `kq`.`iddoithang`)) where `kq`.`trangthai` in ('DA_CONG_BO','DA_DIEU_CHINH') */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_public_lichthidau`
--

/*!50001 DROP VIEW IF EXISTS `vw_public_lichthidau`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_public_lichthidau` AS select `t`.`idtrandau` AS `idtrandau`,`gd`.`tengiaidau` AS `tengiaidau`,`vd`.`tenvongdau` AS `tenvongdau`,`bd`.`tenbang` AS `tenbang`,`t`.`ma_tran` AS `ma_tran`,`t`.`ten_tran` AS `ten_tran`,`d1`.`tendoibong` AS `doi1`,`d2`.`tendoibong` AS `doi2`,`vt`.`tenvitrithidau` AS `tenvitrithidau`,`sd`.`tensandau` AS `tensandau`,`t`.`thoigianbatdau` AS `thoigianbatdau`,`t`.`trangthai` AS `trangthai` from (((((((`trandau` `t` join `giaidau` `gd` on(`gd`.`idgiaidau` = `t`.`idgiaidau`)) join `vongdau` `vd` on(`vd`.`idvongdau` = `t`.`idvongdau`)) left join `bangdau` `bd` on(`bd`.`idbangdau` = `t`.`idbangdau`)) left join `doibong` `d1` on(`d1`.`iddoibong` = `t`.`iddoibong1`)) left join `doibong` `d2` on(`d2`.`iddoibong` = `t`.`iddoibong2`)) left join `sandau` `sd` on(`sd`.`idsandau` = `t`.`idsandau`)) left join `vitrithidau` `vt` on(`vt`.`idvitrithidau` = `sd`.`idvitrithidau`)) where `gd`.`trangthai` in ('DA_CONG_BO','DANG_DIEN_RA','DA_KET_THUC') */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_sandau_daydu_khuvuc`
--

/*!50001 DROP VIEW IF EXISTS `vw_sandau_daydu_khuvuc`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_sandau_daydu_khuvuc` AS select `sd`.`idsandau` AS `idsandau`,`sd`.`tensandau` AS `tensandau`,`sd`.`loaisan` AS `loaisan`,`sd`.`mat_san` AS `mat_san`,`sd`.`kichthuoc` AS `kichthuoc`,`sd`.`succhua` AS `succhua_san`,`sd`.`mota` AS `mota_san`,`sd`.`trangthai` AS `trangthai_san`,`sd`.`ngaytao` AS `ngaytao_san`,`sd`.`ngaycapnhat` AS `ngaycapnhat_san`,`vt`.`idvitrithidau` AS `idvitrithidau`,`vt`.`tenvitrithidau` AS `tenvitrithidau`,`vt`.`loaihinh` AS `loaihinh_vitrithidau`,`vt`.`idkhuvuc_gan_truc_tiep` AS `idkhuvuc_gan_truc_tiep`,`vt`.`makhuvuc_gan_truc_tiep` AS `makhuvuc_gan_truc_tiep`,`vt`.`tenkhuvuc_gan_truc_tiep` AS `tenkhuvuc_gan_truc_tiep`,`vt`.`capkhuvuc_gan_truc_tiep` AS `capkhuvuc_gan_truc_tiep`,`vt`.`id_quocgia` AS `id_quocgia`,`vt`.`ten_quocgia` AS `ten_quocgia`,`vt`.`id_tinhthanh` AS `id_tinhthanh`,`vt`.`ten_tinhthanh` AS `ten_tinhthanh`,`vt`.`id_quanhuyen` AS `id_quanhuyen`,`vt`.`ten_quanhuyen` AS `ten_quanhuyen`,`vt`.`id_xaphuong` AS `id_xaphuong`,`vt`.`ten_xaphuong` AS `ten_xaphuong`,`vt`.`id_donvi` AS `id_donvi`,`vt`.`ten_donvi` AS `ten_donvi`,`vt`.`duong_dan_khuvuc` AS `duong_dan_khuvuc`,`vt`.`diachi` AS `diachi`,`vt`.`diachi_chitiet` AS `diachi_chitiet`,`vt`.`succhua` AS `succhua_vitrithidau`,`vt`.`kinhdo` AS `kinhdo`,`vt`.`vido` AS `vido`,`vt`.`trangthai` AS `trangthai_vitrithidau` from (`sandau` `sd` join `vw_vitrithidau_daydu_khuvuc` `vt` on(`vt`.`idvitrithidau` = `sd`.`idvitrithidau`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_thanhtich_doibong`
--

/*!50001 DROP VIEW IF EXISTS `vw_thanhtich_doibong`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_thanhtich_doibong` AS select `tt`.`idthanhtich` AS `idthanhtich`,`tt`.`iddoibong` AS `iddoibong`,`db`.`tendoibong` AS `tendoibong`,`tt`.`idgiaidau` AS `idgiaidau`,`gd`.`tengiaidau` AS `tengiaidau`,`cg`.`macapgiaidau` AS `macapgiaidau`,`cg`.`tencapgiaidau` AS `tencapgiaidau`,`kv`.`tenkhuvuc` AS `tenkhuvuc`,`tt`.`mua_giai` AS `mua_giai`,`tt`.`hang_dat_duoc` AS `hang_dat_duoc`,`tt`.`danhhieu` AS `danhhieu`,`tt`.`nguon_ghi_nhan` AS `nguon_ghi_nhan`,`tt`.`ngay_cong_nhan` AS `ngay_cong_nhan`,`tt`.`trangthai` AS `trangthai` from ((((`thanhtichdoibong` `tt` join `doibong` `db` on(`db`.`iddoibong` = `tt`.`iddoibong`)) join `giaidau` `gd` on(`gd`.`idgiaidau` = `tt`.`idgiaidau`)) join `capgiaidau` `cg` on(`cg`.`idcapgiaidau` = `tt`.`idcapgiaidau`)) join `khuvuc` `kv` on(`kv`.`idkhuvuc` = `tt`.`idkhuvuc`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_vitrithidau_daydu_khuvuc`
--

/*!50001 DROP VIEW IF EXISTS `vw_vitrithidau_daydu_khuvuc`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_vitrithidau_daydu_khuvuc` AS select `x`.`idvitrithidau` AS `idvitrithidau`,`x`.`tenvitrithidau` AS `tenvitrithidau`,`x`.`loaihinh` AS `loaihinh`,`x`.`idkhuvuc` AS `idkhuvuc_gan_truc_tiep`,`x`.`makhuvuc` AS `makhuvuc_gan_truc_tiep`,`x`.`tenkhuvuc` AS `tenkhuvuc_gan_truc_tiep`,`x`.`capkhuvuc` AS `capkhuvuc_gan_truc_tiep`,`x`.`id_quocgia` AS `id_quocgia`,`x`.`ten_quocgia` AS `ten_quocgia`,`x`.`id_tinhthanh` AS `id_tinhthanh`,`x`.`ten_tinhthanh` AS `ten_tinhthanh`,`x`.`id_quanhuyen` AS `id_quanhuyen`,`x`.`ten_quanhuyen` AS `ten_quanhuyen`,`x`.`id_xaphuong` AS `id_xaphuong`,`x`.`ten_xaphuong` AS `ten_xaphuong`,`x`.`id_donvi` AS `id_donvi`,`x`.`ten_donvi` AS `ten_donvi`,concat_ws(' > ',`x`.`ten_quocgia`,`x`.`ten_tinhthanh`,`x`.`ten_quanhuyen`,`x`.`ten_xaphuong`,`x`.`ten_donvi`) AS `duong_dan_khuvuc`,`x`.`diachi` AS `diachi`,`x`.`diachi_chitiet` AS `diachi_chitiet`,`x`.`succhua` AS `succhua`,`x`.`kinhdo` AS `kinhdo`,`x`.`vido` AS `vido`,`x`.`sdt_lienhe` AS `sdt_lienhe`,`x`.`nguoi_lienhe` AS `nguoi_lienhe`,`x`.`email_lienhe` AS `email_lienhe`,`x`.`mota` AS `mota`,`x`.`trangthai` AS `trangthai`,`x`.`ngaytao` AS `ngaytao`,`x`.`ngaycapnhat` AS `ngaycapnhat` from (select `vt`.`idvitrithidau` AS `idvitrithidau`,`vt`.`tenvitrithidau` AS `tenvitrithidau`,`vt`.`loaihinh` AS `loaihinh`,`vt`.`idkhuvuc` AS `idkhuvuc`,`vt`.`diachi` AS `diachi`,`vt`.`diachi_chitiet` AS `diachi_chitiet`,`vt`.`succhua` AS `succhua`,`vt`.`kinhdo` AS `kinhdo`,`vt`.`vido` AS `vido`,`vt`.`sdt_lienhe` AS `sdt_lienhe`,`vt`.`nguoi_lienhe` AS `nguoi_lienhe`,`vt`.`email_lienhe` AS `email_lienhe`,`vt`.`mota` AS `mota`,`vt`.`trangthai` AS `trangthai`,`vt`.`ngaytao` AS `ngaytao`,`vt`.`ngaycapnhat` AS `ngaycapnhat`,`kv0`.`makhuvuc` AS `makhuvuc`,`kv0`.`tenkhuvuc` AS `tenkhuvuc`,`kv0`.`capkhuvuc` AS `capkhuvuc`,coalesce(case when `kv0`.`capkhuvuc` = 'QUOC_GIA' then `kv0`.`idkhuvuc` end,case when `kv1`.`capkhuvuc` = 'QUOC_GIA' then `kv1`.`idkhuvuc` end,case when `kv2`.`capkhuvuc` = 'QUOC_GIA' then `kv2`.`idkhuvuc` end,case when `kv3`.`capkhuvuc` = 'QUOC_GIA' then `kv3`.`idkhuvuc` end,case when `kv4`.`capkhuvuc` = 'QUOC_GIA' then `kv4`.`idkhuvuc` end) AS `id_quocgia`,coalesce(case when `kv0`.`capkhuvuc` = 'QUOC_GIA' then `kv0`.`tenkhuvuc` end,case when `kv1`.`capkhuvuc` = 'QUOC_GIA' then `kv1`.`tenkhuvuc` end,case when `kv2`.`capkhuvuc` = 'QUOC_GIA' then `kv2`.`tenkhuvuc` end,case when `kv3`.`capkhuvuc` = 'QUOC_GIA' then `kv3`.`tenkhuvuc` end,case when `kv4`.`capkhuvuc` = 'QUOC_GIA' then `kv4`.`tenkhuvuc` end) AS `ten_quocgia`,coalesce(case when `kv0`.`capkhuvuc` = 'TINH_THANH' then `kv0`.`idkhuvuc` end,case when `kv1`.`capkhuvuc` = 'TINH_THANH' then `kv1`.`idkhuvuc` end,case when `kv2`.`capkhuvuc` = 'TINH_THANH' then `kv2`.`idkhuvuc` end,case when `kv3`.`capkhuvuc` = 'TINH_THANH' then `kv3`.`idkhuvuc` end,case when `kv4`.`capkhuvuc` = 'TINH_THANH' then `kv4`.`idkhuvuc` end) AS `id_tinhthanh`,coalesce(case when `kv0`.`capkhuvuc` = 'TINH_THANH' then `kv0`.`tenkhuvuc` end,case when `kv1`.`capkhuvuc` = 'TINH_THANH' then `kv1`.`tenkhuvuc` end,case when `kv2`.`capkhuvuc` = 'TINH_THANH' then `kv2`.`tenkhuvuc` end,case when `kv3`.`capkhuvuc` = 'TINH_THANH' then `kv3`.`tenkhuvuc` end,case when `kv4`.`capkhuvuc` = 'TINH_THANH' then `kv4`.`tenkhuvuc` end) AS `ten_tinhthanh`,coalesce(case when `kv0`.`capkhuvuc` = 'QUAN_HUYEN' then `kv0`.`idkhuvuc` end,case when `kv1`.`capkhuvuc` = 'QUAN_HUYEN' then `kv1`.`idkhuvuc` end,case when `kv2`.`capkhuvuc` = 'QUAN_HUYEN' then `kv2`.`idkhuvuc` end,case when `kv3`.`capkhuvuc` = 'QUAN_HUYEN' then `kv3`.`idkhuvuc` end,case when `kv4`.`capkhuvuc` = 'QUAN_HUYEN' then `kv4`.`idkhuvuc` end) AS `id_quanhuyen`,coalesce(case when `kv0`.`capkhuvuc` = 'QUAN_HUYEN' then `kv0`.`tenkhuvuc` end,case when `kv1`.`capkhuvuc` = 'QUAN_HUYEN' then `kv1`.`tenkhuvuc` end,case when `kv2`.`capkhuvuc` = 'QUAN_HUYEN' then `kv2`.`tenkhuvuc` end,case when `kv3`.`capkhuvuc` = 'QUAN_HUYEN' then `kv3`.`tenkhuvuc` end,case when `kv4`.`capkhuvuc` = 'QUAN_HUYEN' then `kv4`.`tenkhuvuc` end) AS `ten_quanhuyen`,coalesce(case when `kv0`.`capkhuvuc` = 'XA_PHUONG' then `kv0`.`idkhuvuc` end,case when `kv1`.`capkhuvuc` = 'XA_PHUONG' then `kv1`.`idkhuvuc` end,case when `kv2`.`capkhuvuc` = 'XA_PHUONG' then `kv2`.`idkhuvuc` end,case when `kv3`.`capkhuvuc` = 'XA_PHUONG' then `kv3`.`idkhuvuc` end,case when `kv4`.`capkhuvuc` = 'XA_PHUONG' then `kv4`.`idkhuvuc` end) AS `id_xaphuong`,coalesce(case when `kv0`.`capkhuvuc` = 'XA_PHUONG' then `kv0`.`tenkhuvuc` end,case when `kv1`.`capkhuvuc` = 'XA_PHUONG' then `kv1`.`tenkhuvuc` end,case when `kv2`.`capkhuvuc` = 'XA_PHUONG' then `kv2`.`tenkhuvuc` end,case when `kv3`.`capkhuvuc` = 'XA_PHUONG' then `kv3`.`tenkhuvuc` end,case when `kv4`.`capkhuvuc` = 'XA_PHUONG' then `kv4`.`tenkhuvuc` end) AS `ten_xaphuong`,coalesce(case when `kv0`.`capkhuvuc` = 'DON_VI' then `kv0`.`idkhuvuc` end,case when `kv1`.`capkhuvuc` = 'DON_VI' then `kv1`.`idkhuvuc` end,case when `kv2`.`capkhuvuc` = 'DON_VI' then `kv2`.`idkhuvuc` end,case when `kv3`.`capkhuvuc` = 'DON_VI' then `kv3`.`idkhuvuc` end,case when `kv4`.`capkhuvuc` = 'DON_VI' then `kv4`.`idkhuvuc` end) AS `id_donvi`,coalesce(case when `kv0`.`capkhuvuc` = 'DON_VI' then `kv0`.`tenkhuvuc` end,case when `kv1`.`capkhuvuc` = 'DON_VI' then `kv1`.`tenkhuvuc` end,case when `kv2`.`capkhuvuc` = 'DON_VI' then `kv2`.`tenkhuvuc` end,case when `kv3`.`capkhuvuc` = 'DON_VI' then `kv3`.`tenkhuvuc` end,case when `kv4`.`capkhuvuc` = 'DON_VI' then `kv4`.`tenkhuvuc` end) AS `ten_donvi` from (((((`vitrithidau` `vt` join `khuvuc` `kv0` on(`kv0`.`idkhuvuc` = `vt`.`idkhuvuc`)) left join `khuvuc` `kv1` on(`kv1`.`idkhuvuc` = `kv0`.`idkhuvuccha`)) left join `khuvuc` `kv2` on(`kv2`.`idkhuvuc` = `kv1`.`idkhuvuccha`)) left join `khuvuc` `kv3` on(`kv3`.`idkhuvuc` = `kv2`.`idkhuvuccha`)) left join `khuvuc` `kv4` on(`kv4`.`idkhuvuc` = `kv3`.`idkhuvuccha`))) `x` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-20 21:39:58
