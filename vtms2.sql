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
  CONSTRAINT `chk_bangdau_ngay` CHECK (`thoigianbatdau` is null or `thoigianketthuc` is null or `thoigianketthuc` > `thoigianbatdau`)
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
  `iddonvi` int(11) DEFAULT NULL,
  `idbantochuccha` int(11) DEFAULT NULL,
  `donvi` varchar(300) NOT NULL,
  `chucvu` varchar(200) DEFAULT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'CHO_XAC_NHAN',
  PRIMARY KEY (`idbantochuc`),
  UNIQUE KEY `idnguoidung` (`idnguoidung`),
  KEY `fk_btc_capbtc` (`idcapbantochuc`),
  KEY `fk_btc_khuvuc` (`idkhuvucquanly`),
  KEY `fk_btc_cha` (`idbantochuccha`),
  KEY `idx_btc_donvi` (`iddonvi`),
  CONSTRAINT `fk_btc_capbtc` FOREIGN KEY (`idcapbantochuc`) REFERENCES `capbantochuc` (`idcapbantochuc`) ON UPDATE CASCADE,
  CONSTRAINT `fk_btc_cha` FOREIGN KEY (`idbantochuccha`) REFERENCES `bantochuc` (`idbantochuc`) ON UPDATE CASCADE,
  CONSTRAINT `fk_btc_donvi` FOREIGN KEY (`iddonvi`) REFERENCES `donvi` (`iddonvi`) ON UPDATE CASCADE,
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
INSERT INTO `bantochuc` VALUES (1,2,1,1,1,NULL,'Liên đoàn Bóng chuyền VN','BTC cấp quốc gia','HOAT_DONG'),(2,3,2,2,2,1,'Sở VH-TT Thành phố Hồ Chí Minh','BTC cấp tỉnh/thành','HOAT_DONG'),(3,4,3,20,10,2,'Trung tâm VH-TT Phường Sài Gòn','BTC tổ chức giải cấp xã/phường','HOAT_DONG'),(4,5,3,20,11,2,'Trung tâm TDTT Phường Sài Gòn','BTC đại diện đăng ký đội','HOAT_DONG'),(5,10,2,2,3,1,'Trung tâm huấn luyện và thi đấu TDTT Thành phố Hồ Chí Minh','BTC đại diện đăng ký đội cấp tỉnh/thành','HOAT_DONG'),(6,11,2,3,5,1,'Trung tâm huấn luyện và thi đấu TDTT Thành phố Hà Nội','BTC đại diện đăng ký đội cấp tỉnh/thành','HOAT_DONG'),(7,12,3,21,15,2,'Trung tâm TDTT Phường Bến Thành','BTC đại diện đăng ký đội cấp xã/phường','HOAT_DONG'),(8,13,3,30,16,9,'Trung tâm TDTT Phường Hoàn Kiếm','BTC đại diện đăng ký đội cấp xã/phường','HOAT_DONG'),(9,14,2,3,4,1,'Sở VH-TT Thành phố Hà Nội','BTC tổ chức giải cấp tỉnh/thành','HOAT_DONG'),(10,15,3,21,13,2,'Trung tâm VH-TT Phường Bến Thành','BTC tổ chức giải cấp xã/phường','HOAT_DONG'),(11,16,3,30,14,9,'Trung tâm VH-TT Phường Hoàn Kiếm','BTC tổ chức giải cấp xã/phường','HOAT_DONG'),(12,17,3,20,NULL,2,'Tư nhân','BTC đại diện đội bóng tư nhân','HOAT_DONG');
/*!40000 ALTER TABLE `bantochuc` ENABLE KEYS */;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_bantochuc_bi
BEFORE INSERT ON bantochuc
FOR EACH ROW
BEGIN
    DECLARE v_capbtc VARCHAR(50);
    DECLARE v_capkv VARCHAR(50);
    DECLARE v_thutu_btc INT;
    DECLARE v_thutu_cha INT;
    DECLARE v_donvi_khuvuc INT;
    DECLARE v_donvi_trangthai VARCHAR(50);
    DECLARE v_la_cap_thap_nhat TINYINT(1);

    SELECT c.capkhuvucquanly, c.thutu, k.capkhuvuc, cq.la_cap_thap_nhat
      INTO v_capbtc, v_thutu_btc, v_capkv, v_la_cap_thap_nhat
      FROM capbantochuc c
      JOIN khuvuc k ON k.idkhuvuc = NEW.idkhuvucquanly
      JOIN capchinhquyen cq ON cq.macap = k.capkhuvuc
     WHERE c.idcapbantochuc = NEW.idcapbantochuc;

    IF v_capbtc <> v_capkv THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cap BTC phai khop cap khu vuc quan ly.';
    END IF;

    IF NEW.iddonvi IS NULL THEN
        IF v_la_cap_thap_nhat <> 1 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'BTC khong thuoc don vi chi duoc tao o cap thap nhat.';
        END IF;
    ELSE
        SELECT idkhuvuc, trangthai
          INTO v_donvi_khuvuc, v_donvi_trangthai
          FROM donvi
         WHERE iddonvi = NEW.iddonvi;

        IF v_donvi_trangthai <> 'HOAT_DONG' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Don vi cua BTC phai dang hoat dong.';
        END IF;

        IF v_donvi_khuvuc <> NEW.idkhuvucquanly THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Don vi cua BTC khong thuoc khu vuc quan ly cua BTC.';
        END IF;
    END IF;

    IF NEW.idbantochuccha IS NOT NULL THEN
        SELECT c.thutu
          INTO v_thutu_cha
          FROM bantochuc b
          JOIN capbantochuc c ON c.idcapbantochuc = b.idcapbantochuc
         WHERE b.idbantochuc = NEW.idbantochuccha;

        IF v_thutu_cha >= v_thutu_btc THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'BTC cha phai co cap cao hon BTC con.';
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
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_bantochuc_bu
BEFORE UPDATE ON bantochuc
FOR EACH ROW
BEGIN
    DECLARE v_capbtc VARCHAR(50);
    DECLARE v_capkv VARCHAR(50);
    DECLARE v_thutu_btc INT;
    DECLARE v_thutu_cha INT;
    DECLARE v_donvi_khuvuc INT;
    DECLARE v_donvi_trangthai VARCHAR(50);
    DECLARE v_la_cap_thap_nhat TINYINT(1);

    SELECT c.capkhuvucquanly, c.thutu, k.capkhuvuc, cq.la_cap_thap_nhat
      INTO v_capbtc, v_thutu_btc, v_capkv, v_la_cap_thap_nhat
      FROM capbantochuc c
      JOIN khuvuc k ON k.idkhuvuc = NEW.idkhuvucquanly
      JOIN capchinhquyen cq ON cq.macap = k.capkhuvuc
     WHERE c.idcapbantochuc = NEW.idcapbantochuc;

    IF v_capbtc <> v_capkv THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cap BTC phai khop cap khu vuc quan ly.';
    END IF;

    IF NEW.iddonvi IS NULL THEN
        IF v_la_cap_thap_nhat <> 1 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'BTC khong thuoc don vi chi duoc tao o cap thap nhat.';
        END IF;
    ELSE
        SELECT idkhuvuc, trangthai
          INTO v_donvi_khuvuc, v_donvi_trangthai
          FROM donvi
         WHERE iddonvi = NEW.iddonvi;

        IF v_donvi_trangthai <> 'HOAT_DONG' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Don vi cua BTC phai dang hoat dong.';
        END IF;

        IF v_donvi_khuvuc <> NEW.idkhuvucquanly THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Don vi cua BTC khong thuoc khu vuc quan ly cua BTC.';
        END IF;
    END IF;

    IF NEW.idbantochuccha IS NOT NULL THEN
        SELECT c.thutu
          INTO v_thutu_cha
          FROM bantochuc b
          JOIN capbantochuc c ON c.idcapbantochuc = b.idcapbantochuc
         WHERE b.idbantochuc = NEW.idbantochuccha;

        IF v_thutu_cha >= v_thutu_btc THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'BTC cha phai co cap cao hon BTC con.';
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
  KEY `fk_capbtc_khuvuc_capchinhquyen` (`capkhuvucquanly`),
  CONSTRAINT `fk_capbtc_khuvuc_capchinhquyen` FOREIGN KEY (`capkhuvucquanly`) REFERENCES `capchinhquyen` (`macap`) ON UPDATE CASCADE,
  CONSTRAINT `fk_capbtc_ma_capchinhquyen` FOREIGN KEY (`macapbantochuc`) REFERENCES `capchinhquyen` (`macap`) ON UPDATE CASCADE,
  CONSTRAINT `chk_capbtc_thutu` CHECK (`thutu` > 0),
  CONSTRAINT `chk_capbtc_trangthai` CHECK (`trangthai` in ('HOAT_DONG','NGUNG_SU_DUNG'))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `capbantochuc`
--

LOCK TABLES `capbantochuc` WRITE;
/*!40000 ALTER TABLE `capbantochuc` DISABLE KEYS */;
INSERT INTO `capbantochuc` VALUES (1,'QUOC_GIA','Ban tổ chức cấp quốc gia','QUOC_GIA',1,'BTC quản lý phạm vi quốc gia.','HOAT_DONG'),(2,'TINH_THANH','Ban tổ chức cấp tỉnh/thành','TINH_THANH',2,'BTC quản lý phạm vi tỉnh/thành.','HOAT_DONG'),(3,'XA_PHUONG','Ban tổ chức cấp xã/phường','XA_PHUONG',3,'BTC quản lý phạm vi xã/phường.','HOAT_DONG');
/*!40000 ALTER TABLE `capbantochuc` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `capchinhquyen`
--

DROP TABLE IF EXISTS `capchinhquyen`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `capchinhquyen` (
  `macap` varchar(50) NOT NULL,
  `tencap` varchar(200) NOT NULL,
  `macapcha` varchar(50) DEFAULT NULL,
  `thutu` int(11) NOT NULL,
  `la_cap_thap_nhat` tinyint(1) NOT NULL DEFAULT 0,
  `mota` varchar(1000) DEFAULT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'HOAT_DONG',
  PRIMARY KEY (`macap`),
  UNIQUE KEY `uq_capchinhquyen_thutu` (`thutu`),
  KEY `idx_capchinhquyen_capcha` (`macapcha`),
  CONSTRAINT `fk_capchinhquyen_capcha` FOREIGN KEY (`macapcha`) REFERENCES `capchinhquyen` (`macap`) ON UPDATE CASCADE,
  CONSTRAINT `chk_capchinhquyen_thutu` CHECK (`thutu` > 0),
  CONSTRAINT `chk_capchinhquyen_bool` CHECK (`la_cap_thap_nhat` in (0,1)),
  CONSTRAINT `chk_capchinhquyen_trangthai` CHECK (`trangthai` in ('HOAT_DONG','NGUNG_SU_DUNG'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `capchinhquyen`
--

LOCK TABLES `capchinhquyen` WRITE;
/*!40000 ALTER TABLE `capchinhquyen` DISABLE KEYS */;
INSERT INTO `capchinhquyen` VALUES ('QUOC_GIA','Quốc gia',NULL,1,0,'Cấp quản lý quốc gia.','HOAT_DONG'),('TINH_THANH','Tỉnh/thành','QUOC_GIA',2,0,'Cấp tỉnh/thành trực thuộc quốc gia.','HOAT_DONG'),('XA_PHUONG','Xã/phường','TINH_THANH',3,1,'Cấp thấp nhất hiện tại sau thay đổi địa giới.','HOAT_DONG');
/*!40000 ALTER TABLE `capchinhquyen` ENABLE KEYS */;
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
  KEY `fk_capgd_scope_capchinhquyen` (`capkhuvucphamvi`),
  KEY `fk_capgd_participant_capchinhquyen` (`capdoituongthamgia`),
  CONSTRAINT `fk_capgd_ma_capchinhquyen` FOREIGN KEY (`macapgiaidau`) REFERENCES `capchinhquyen` (`macap`) ON UPDATE CASCADE,
  CONSTRAINT `fk_capgd_participant_capchinhquyen` FOREIGN KEY (`capdoituongthamgia`) REFERENCES `capchinhquyen` (`macap`) ON UPDATE CASCADE,
  CONSTRAINT `fk_capgd_scope_capchinhquyen` FOREIGN KEY (`capkhuvucphamvi`) REFERENCES `capchinhquyen` (`macap`) ON UPDATE CASCADE,
  CONSTRAINT `chk_capgd_trangthai` CHECK (`trangthai` in ('HOAT_DONG','NGUNG_SU_DUNG'))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `capgiaidau`
--

LOCK TABLES `capgiaidau` WRITE;
/*!40000 ALTER TABLE `capgiaidau` DISABLE KEYS */;
INSERT INTO `capgiaidau` VALUES (1,'QUOC_GIA','Giải cấp quốc gia','QUOC_GIA','TINH_THANH',0,'Giải cấp quốc gia chọn đội đại diện từ tỉnh/thành.','HOAT_DONG'),(2,'TINH_THANH','Giải cấp tỉnh/thành','TINH_THANH','XA_PHUONG',1,'Giải cấp tỉnh/thành chọn đội đại diện từ xã/phường.','HOAT_DONG'),(3,'XA_PHUONG','Giải cấp xã/phường','XA_PHUONG','XA_PHUONG',1,'Giải cấp xã/phường cho các đội cùng cấp tham gia.','HOAT_DONG');
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
) ENGINE=InnoDB AUTO_INCREMENT=10247 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chitietdoihinh`
--

LOCK TABLES `chitietdoihinh` WRITE;
/*!40000 ALTER TABLE `chitietdoihinh` DISABLE KEYS */;
INSERT INTO `chitietdoihinh` VALUES (10011,101,10011,'CHU_CONG',1,'Chủ công'),(10012,101,10012,'PHU_CONG',2,'Phụ công'),(10013,101,10013,'CHUYEN_HAI',3,'Chuyền hai'),(10014,101,10014,'DOI_CHUYEN',4,'Đối chuyền'),(10015,101,10015,'LIBERO',5,'Libero'),(10016,101,10016,'DOI_TRU',6,'Dự bị'),(10021,102,10021,'CHU_CONG',1,'Chủ công'),(10022,102,10022,'PHU_CONG',2,'Phụ công'),(10023,102,10023,'CHUYEN_HAI',3,'Chuyền hai'),(10024,102,10024,'DOI_CHUYEN',4,'Đối chuyền'),(10025,102,10025,'LIBERO',5,'Libero'),(10026,102,10026,'DOI_TRU',6,'Dự bị'),(10031,103,10031,'CHU_CONG',1,'Chủ công'),(10032,103,10032,'PHU_CONG',2,'Phụ công'),(10033,103,10033,'CHUYEN_HAI',3,'Chuyền hai'),(10034,103,10034,'DOI_CHUYEN',4,'Đối chuyền'),(10035,103,10035,'LIBERO',5,'Libero'),(10036,103,10036,'DOI_TRU',6,'Dự bị'),(10041,104,10041,'CHU_CONG',1,'Chủ công'),(10042,104,10042,'PHU_CONG',2,'Phụ công'),(10043,104,10043,'CHUYEN_HAI',3,'Chuyền hai'),(10044,104,10044,'DOI_CHUYEN',4,'Đối chuyền'),(10045,104,10045,'LIBERO',5,'Libero'),(10046,104,10046,'DOI_TRU',6,'Dự bị'),(10051,105,10051,'CHU_CONG',1,'Chủ công'),(10052,105,10052,'PHU_CONG',2,'Phụ công'),(10053,105,10053,'CHUYEN_HAI',3,'Chuyền hai'),(10054,105,10054,'DOI_CHUYEN',4,'Đối chuyền'),(10055,105,10055,'LIBERO',5,'Libero'),(10056,105,10056,'DOI_TRU',6,'Dự bị'),(10061,106,10061,'CHU_CONG',1,'Chủ công'),(10062,106,10062,'PHU_CONG',2,'Phụ công'),(10063,106,10063,'CHUYEN_HAI',3,'Chuyền hai'),(10064,106,10064,'DOI_CHUYEN',4,'Đối chuyền'),(10065,106,10065,'LIBERO',5,'Libero'),(10066,106,10066,'DOI_TRU',6,'Dự bị'),(10071,107,10071,'CHU_CONG',1,'Chủ công'),(10072,107,10072,'PHU_CONG',2,'Phụ công'),(10073,107,10073,'CHUYEN_HAI',3,'Chuyền hai'),(10074,107,10074,'DOI_CHUYEN',4,'Đối chuyền'),(10075,107,10075,'LIBERO',5,'Libero'),(10076,107,10076,'DOI_TRU',6,'Dự bị'),(10081,108,10081,'CHU_CONG',1,'Chủ công'),(10082,108,10082,'PHU_CONG',2,'Phụ công'),(10083,108,10083,'CHUYEN_HAI',3,'Chuyền hai'),(10084,108,10084,'DOI_CHUYEN',4,'Đối chuyền'),(10085,108,10085,'LIBERO',5,'Libero'),(10086,108,10086,'DOI_TRU',6,'Dự bị'),(10091,109,10091,'CHU_CONG',1,'Chủ công'),(10092,109,10092,'PHU_CONG',2,'Phụ công'),(10093,109,10093,'CHUYEN_HAI',3,'Chuyền hai'),(10094,109,10094,'DOI_CHUYEN',4,'Đối chuyền'),(10095,109,10095,'LIBERO',5,'Libero'),(10096,109,10096,'DOI_TRU',6,'Dự bị'),(10101,110,10101,'CHU_CONG',1,'Chủ công'),(10102,110,10102,'PHU_CONG',2,'Phụ công'),(10103,110,10103,'CHUYEN_HAI',3,'Chuyền hai'),(10104,110,10104,'DOI_CHUYEN',4,'Đối chuyền'),(10105,110,10105,'LIBERO',5,'Libero'),(10106,110,10106,'DOI_TRU',6,'Dự bị'),(10111,111,10111,'CHU_CONG',1,'Chủ công'),(10112,111,10112,'PHU_CONG',2,'Phụ công'),(10113,111,10113,'CHUYEN_HAI',3,'Chuyền hai'),(10114,111,10114,'DOI_CHUYEN',4,'Đối chuyền'),(10115,111,10115,'LIBERO',5,'Libero'),(10116,111,10116,'DOI_TRU',6,'Dự bị'),(10121,112,10121,'CHU_CONG',1,'Chủ công'),(10122,112,10122,'PHU_CONG',2,'Phụ công'),(10123,112,10123,'CHUYEN_HAI',3,'Chuyền hai'),(10124,112,10124,'DOI_CHUYEN',4,'Đối chuyền'),(10125,112,10125,'LIBERO',5,'Libero'),(10126,112,10126,'DOI_TRU',6,'Dự bị'),(10131,113,10131,'CHU_CONG',1,'Chủ công'),(10132,113,10132,'PHU_CONG',2,'Phụ công'),(10133,113,10133,'CHUYEN_HAI',3,'Chuyền hai'),(10134,113,10134,'DOI_CHUYEN',4,'Đối chuyền'),(10135,113,10135,'LIBERO',5,'Libero'),(10136,113,10136,'DOI_TRU',6,'Dự bị'),(10141,114,10141,'CHU_CONG',1,'Chủ công'),(10142,114,10142,'PHU_CONG',2,'Phụ công'),(10143,114,10143,'CHUYEN_HAI',3,'Chuyền hai'),(10144,114,10144,'DOI_CHUYEN',4,'Đối chuyền'),(10145,114,10145,'LIBERO',5,'Libero'),(10146,114,10146,'DOI_TRU',6,'Dự bị'),(10151,115,10151,'CHU_CONG',1,'Chủ công'),(10152,115,10152,'PHU_CONG',2,'Phụ công'),(10153,115,10153,'CHUYEN_HAI',3,'Chuyền hai'),(10154,115,10154,'DOI_CHUYEN',4,'Đối chuyền'),(10155,115,10155,'LIBERO',5,'Libero'),(10156,115,10156,'DOI_TRU',6,'Dự bị'),(10161,116,10161,'CHU_CONG',1,'Chủ công'),(10162,116,10162,'PHU_CONG',2,'Phụ công'),(10163,116,10163,'CHUYEN_HAI',3,'Chuyền hai'),(10164,116,10164,'DOI_CHUYEN',4,'Đối chuyền'),(10165,116,10165,'LIBERO',5,'Libero'),(10166,116,10166,'DOI_TRU',6,'Dự bị'),(10171,117,10171,'CHU_CONG',1,'Chủ công'),(10172,117,10172,'PHU_CONG',2,'Phụ công'),(10173,117,10173,'CHUYEN_HAI',3,'Chuyền hai'),(10174,117,10174,'DOI_CHUYEN',4,'Đối chuyền'),(10175,117,10175,'LIBERO',5,'Libero'),(10176,117,10176,'DOI_TRU',6,'Dự bị'),(10181,118,10181,'CHU_CONG',1,'Chủ công'),(10182,118,10182,'PHU_CONG',2,'Phụ công'),(10183,118,10183,'CHUYEN_HAI',3,'Chuyền hai'),(10184,118,10184,'DOI_CHUYEN',4,'Đối chuyền'),(10185,118,10185,'LIBERO',5,'Libero'),(10186,118,10186,'DOI_TRU',6,'Dự bị'),(10191,119,10191,'CHU_CONG',1,'Chủ công'),(10192,119,10192,'PHU_CONG',2,'Phụ công'),(10193,119,10193,'CHUYEN_HAI',3,'Chuyền hai'),(10194,119,10194,'DOI_CHUYEN',4,'Đối chuyền'),(10195,119,10195,'LIBERO',5,'Libero'),(10196,119,10196,'DOI_TRU',6,'Dự bị'),(10201,120,10201,'CHU_CONG',1,'Chủ công'),(10202,120,10202,'PHU_CONG',2,'Phụ công'),(10203,120,10203,'CHUYEN_HAI',3,'Chuyền hai'),(10204,120,10204,'DOI_CHUYEN',4,'Đối chuyền'),(10205,120,10205,'LIBERO',5,'Libero'),(10206,120,10206,'DOI_TRU',6,'Dự bị'),(10211,121,10211,'CHU_CONG',1,'Chủ công'),(10212,121,10212,'PHU_CONG',2,'Phụ công'),(10213,121,10213,'CHUYEN_HAI',3,'Chuyền hai'),(10214,121,10214,'DOI_CHUYEN',4,'Đối chuyền'),(10215,121,10215,'LIBERO',5,'Libero'),(10216,121,10216,'DOI_TRU',6,'Dự bị'),(10221,122,10221,'CHU_CONG',1,'Chủ công'),(10222,122,10222,'PHU_CONG',2,'Phụ công'),(10223,122,10223,'CHUYEN_HAI',3,'Chuyền hai'),(10224,122,10224,'DOI_CHUYEN',4,'Đối chuyền'),(10225,122,10225,'LIBERO',5,'Libero'),(10226,122,10226,'DOI_TRU',6,'Dự bị'),(10231,123,10231,'CHU_CONG',1,'Chủ công'),(10232,123,10232,'PHU_CONG',2,'Phụ công'),(10233,123,10233,'CHUYEN_HAI',3,'Chuyền hai'),(10234,123,10234,'DOI_CHUYEN',4,'Đối chuyền'),(10235,123,10235,'LIBERO',5,'Libero'),(10236,123,10236,'DOI_TRU',6,'Dự bị'),(10241,124,10241,'CHU_CONG',1,'Chủ công'),(10242,124,10242,'PHU_CONG',2,'Phụ công'),(10243,124,10243,'CHUYEN_HAI',3,'Chuyền hai'),(10244,124,10244,'DOI_CHUYEN',4,'Đối chuyền'),(10245,124,10245,'LIBERO',5,'Libero'),(10246,124,10246,'DOI_TRU',6,'Dự bị');
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
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dangkygiaidau`
--

LOCK TABLES `dangkygiaidau` WRITE;
/*!40000 ALTER TABLE `dangkygiaidau` DISABLE KEYS */;
INSERT INTO `dangkygiaidau` VALUES (15,108,5,5,105,NULL,'TU_DANG_KY','2026-05-22 14:55:31','DA_DUYET',NULL,NULL),(16,109,1,1,101,NULL,'TU_DANG_KY','2026-05-22 16:42:04','DA_DUYET',NULL,NULL),(17,109,2,2,102,NULL,'TU_DANG_KY','2026-05-22 16:42:32','DA_DUYET',NULL,NULL);
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
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_dangkygiaidau_bi
BEFORE INSERT ON dangkygiaidau
FOR EACH ROW
BEGIN
    DECLARE v_scope INT;
    DECLARE v_giai_cap INT;
    DECLARE v_team_kv INT;
    DECLARE v_team_status VARCHAR(50);
    DECLARE v_team_cap_nguon INT;
    DECLARE v_team_cap_duoc_tham_gia INT;
    DECLARE v_team_cap_hieu_luc INT;

    SELECT gd.idkhuvucphamvi, gd.idcapgiaidau
    INTO v_scope, v_giai_cap
    FROM giaidau gd
    WHERE gd.idgiaidau = NEW.idgiaidau;

    SELECT
        d.idkhuvucdaidien,
        d.trangthai,
        cgnguon.idcapgiaidau,
        d.idcapgiaidau_duoc_tham_gia
    INTO
        v_team_kv,
        v_team_status,
        v_team_cap_nguon,
        v_team_cap_duoc_tham_gia
    FROM doibong d
    JOIN khuvuc k ON k.idkhuvuc = d.idkhuvucdaidien
    LEFT JOIN capgiaidau cgnguon ON cgnguon.macapgiaidau = k.capkhuvuc
    WHERE d.iddoibong = NEW.iddoibong;

    IF v_team_status <> 'HOAT_DONG' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Chi doi dang hoat dong moi duoc dang ky giai.';
    END IF;

    IF v_team_cap_duoc_tham_gia IS NOT NULL
       AND (v_team_cap_nguon IS NULL OR v_team_cap_duoc_tham_gia < v_team_cap_nguon) THEN
        SET v_team_cap_hieu_luc = v_team_cap_duoc_tham_gia;
    ELSE
        SET v_team_cap_hieu_luc = v_team_cap_nguon;
    END IF;

    IF v_team_cap_hieu_luc IS NULL OR v_giai_cap < v_team_cap_hieu_luc THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doi bong chua duoc duyet tham gia cap giai nay.';
    END IF;

    IF fn_khuvuc_la_con(v_team_kv, v_scope) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doi dang ky khong thuoc pham vi khu vuc cua giai.';
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
  KEY `idx_decu_trangthai` (`trangthai`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `decutucachthamgia`
--

LOCK TABLES `decutucachthamgia` WRITE;
/*!40000 ALTER TABLE `decutucachthamgia` DISABLE KEYS */;
INSERT INTO `decutucachthamgia` VALUES (1,1,1,101,102,3,2,3,2,'DA_DE_CU','Đã xem HLV và toàn bộ VĐV đang tham gia của đội.','Đề cử đội đủ điều kiện tham gia giải cấp cao hơn.',NULL,4,4,NULL,'2026-05-22 22:13:24','2026-05-22 22:20:14',NULL,'2026-05-22 22:13:24','2026-05-22 22:20:14');
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
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `diemset`
--

LOCK TABLES `diemset` WRITE;
/*!40000 ALTER TABLE `diemset` DISABLE KEYS */;
INSERT INTO `diemset` VALUES (44,13,1,17,15,1),(45,13,2,17,15,1),(46,13,3,17,15,1);
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
  CONSTRAINT `fk_dktg_capdoi_capchinhquyen` FOREIGN KEY (`capdoituongthamgia`) REFERENCES `capchinhquyen` (`macap`) ON UPDATE CASCADE,
  CONSTRAINT `fk_dktg_capnguon` FOREIGN KEY (`idcapgiaidau_thanh_tich_nguon`) REFERENCES `capgiaidau` (`idcapgiaidau`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_dktg_giaidau` FOREIGN KEY (`idgiaidau`) REFERENCES `giaidau` (`idgiaidau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_dktg_quytac` FOREIGN KEY (`idquytac`) REFERENCES `quytacchondoi` (`idquytac`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_dktg_yeucau_v2` CHECK (`yeu_cau_thanh_tich` in ('KHONG_YEU_CAU','VO_DICH','A_QUAN','HANG_BA','TOP_N','THEO_XEP_HANG','BTC_CHON','DAC_CACH')),
  CONSTRAINT `chk_dktg_hang_v2` CHECK (`hang_toi_thieu_duoc_phep` is null or `hang_toi_thieu_duoc_phep` >= 1),
  CONSTRAINT `chk_dktg_mua_v2` CHECK (`so_mua_giai_gan_nhat_duoc_tinh` is null or `so_mua_giai_gan_nhat_duoc_tinh` >= 1),
  CONSTRAINT `chk_dktg_bool_v2` CHECK (`chi_tinh_giai_chinh_thuc` in (0,1) and `bat_buoc_cung_khuvuc` in (0,1) and `cho_phep_btc_duyet_ngoai_le` in (0,1)),
  CONSTRAINT `chk_dktg_trangthai_v2` CHECK (`trangthai` in ('HOAT_DONG','TAM_NGUNG','NGUNG_SU_DUNG')),
  CONSTRAINT `chk_dktg_req_logic_v2` CHECK (`yeu_cau_thanh_tich` in ('KHONG_YEU_CAU','BTC_CHON','DAC_CACH') and `idcapgiaidau_thanh_tich_nguon` is null or `yeu_cau_thanh_tich` in ('VO_DICH','A_QUAN','HANG_BA','TOP_N','THEO_XEP_HANG') and `idcapgiaidau_thanh_tich_nguon` is not null),
  CONSTRAINT `chk_dktg_topn_logic_v2` CHECK (`yeu_cau_thanh_tich` <> 'TOP_N' or `yeu_cau_thanh_tich` = 'TOP_N' and `hang_toi_thieu_duoc_phep` is not null and `hang_toi_thieu_duoc_phep` >= 1)
) ENGINE=InnoDB AUTO_INCREMENT=110 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dieukienthamgiagiai`
--

LOCK TABLES `dieukienthamgiagiai` WRITE;
/*!40000 ALTER TABLE `dieukienthamgiagiai` DISABLE KEYS */;
INSERT INTO `dieukienthamgiagiai` VALUES (101,101,101,'Tự đăng ký cấp xã/phường','XA_PHUONG','KHONG_YEU_CAU',NULL,NULL,NULL,0,1,1,'Đội ở cấp xã/phường có thể đăng ký giải cùng khu vực.','HOAT_DONG','2026-05-22 10:47:00',NULL),(102,102,102,'Vô địch cấp xã/phường','XA_PHUONG','VO_DICH',3,NULL,1,1,1,1,'Đội xã/phường đủ điều kiện đi lên giải cấp tỉnh/thành.','HOAT_DONG','2026-05-22 10:47:00',NULL),(103,103,103,'Vô địch cấp tỉnh/thành','TINH_THANH','VO_DICH',2,NULL,1,1,1,1,'Đội tỉnh/thành đủ điều kiện đi lên giải cấp quốc gia.','HOAT_DONG','2026-05-22 10:47:00',NULL),(104,108,110,'Điều kiện tham gia - Không yêu cầu thành tích #1 - 6a100a2b3ae0a','XA_PHUONG','KHONG_YEU_CAU',NULL,NULL,NULL,0,1,0,NULL,'HOAT_DONG','2026-05-22 14:47:55',NULL),(105,109,111,'Điều kiện tham gia - Không yêu cầu thành tích #1 - 6a1024a8ba73b','XA_PHUONG','KHONG_YEU_CAU',NULL,NULL,NULL,0,1,0,NULL,'NGUNG_SU_DUNG','2026-05-22 16:40:56','2026-05-22 17:09:03'),(106,109,112,'Điều kiện tham gia - Không yêu cầu thành tích #1 - 6a10270808791','XA_PHUONG','KHONG_YEU_CAU',NULL,NULL,NULL,0,1,0,NULL,'NGUNG_SU_DUNG','2026-05-22 16:51:04','2026-05-22 17:09:03'),(107,109,113,'Điều kiện tham gia - Không yêu cầu thành tích #1 - 6a10272f8834a','XA_PHUONG','KHONG_YEU_CAU',NULL,NULL,NULL,0,1,0,NULL,'NGUNG_SU_DUNG','2026-05-22 16:51:43','2026-05-22 17:09:03'),(108,109,114,'Điều kiện tham gia - Không yêu cầu thành tích #1 - 6a1028e1ad0d4','XA_PHUONG','KHONG_YEU_CAU',NULL,NULL,NULL,0,1,0,NULL,'NGUNG_SU_DUNG','2026-05-22 16:58:57','2026-05-22 17:09:03'),(109,109,115,'Điều kiện tham gia - Không yêu cầu thành tích #1 - 6a102b3f86d37','XA_PHUONG','KHONG_YEU_CAU',NULL,NULL,NULL,0,1,0,NULL,'HOAT_DONG','2026-05-22 17:09:03',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=116 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dieulegiaidau`
--

LOCK TABLES `dieulegiaidau` WRITE;
/*!40000 ALTER TABLE `dieulegiaidau` DISABLE KEYS */;
INSERT INTO `dieulegiaidau` VALUES (110,108,'Điều lệ giải đấu','---VTMS_DIEU_LE_META---\n{\"le_phi_tham_gia\":\"0\",\"loai_doi_duoc_tham_gia\":\"\"}',NULL,2,10,6,14,NULL,NULL,1,1,0.00,NULL,NULL,'2026-05-22 14:47:55'),(115,109,'Điều lệ giải đấu','---VTMS_DIEU_LE_META---\n{\"le_phi_tham_gia\":\"0\",\"loai_doi_duoc_tham_gia\":\"\"}',NULL,2,10,6,14,NULL,NULL,1,1,0.00,NULL,NULL,'2026-05-22 17:09:03');
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
  `idcapgiaidau_duoc_tham_gia` int(11) DEFAULT NULL,
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
  KEY `idx_doibong_cap_duoc_tham_gia` (`idcapgiaidau_duoc_tham_gia`),
  CONSTRAINT `fk_doibong_cap_duoc_tham_gia` FOREIGN KEY (`idcapgiaidau_duoc_tham_gia`) REFERENCES `capgiaidau` (`idcapgiaidau`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_doibong_hlv` FOREIGN KEY (`idhuanluyenvien`) REFERENCES `huanluyenvien` (`idhuanluyenvien`) ON UPDATE CASCADE,
  CONSTRAINT `fk_doibong_khuvuc` FOREIGN KEY (`idkhuvucdaidien`) REFERENCES `khuvuc` (`idkhuvuc`) ON UPDATE CASCADE,
  CONSTRAINT `chk_doibong_trangthai` CHECK (`trangthai` in ('HOAT_DONG','CHO_DUYET','TAM_KHOA','GIAI_THE'))
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doibong`
--

LOCK TABLES `doibong` WRITE;
/*!40000 ALTER TABLE `doibong` DISABLE KEYS */;
INSERT INTO `doibong` VALUES (1,'Đội Trung tâm TDTT Phường Sài Gòn',NULL,20,NULL,'Phường Sài Gòn','Đội bóng đại diện đơn vị cấp xã/phường.',1,0.00,'HOAT_DONG','2026-05-22 10:47:00',NULL),(2,'Đội Tư nhân Phường Sài Gòn',NULL,20,NULL,'Phường Sài Gòn','Đội bóng của HLV tư nhân ở cấp thấp nhất.',2,0.00,'HOAT_DONG','2026-05-22 10:47:00',NULL),(3,'Đội tuyển Thành phố Hồ Chí Minh',NULL,2,NULL,'Thành phố Hồ Chí Minh','Đội đại diện tỉnh/thành đi thi đấu cấp quốc gia.',3,0.00,'HOAT_DONG','2026-05-22 10:47:00',NULL),(4,'Đội tuyển Thành phố Hà Nội',NULL,3,NULL,'Thành phố Hà Nội','Đội đại diện tỉnh/thành trong dữ liệu mẫu.',4,0.00,'HOAT_DONG','2026-05-22 10:47:00',NULL),(5,'Đội TDTT Phường Sài Gòn 02',NULL,20,NULL,'Phường Sài Gòn, Thành phố Hồ Chí Minh','Đội của Trung tâm TDTT Phường Sài Gòn.',5,0.00,'HOAT_DONG','2026-05-22 13:39:43',NULL),(6,'Đội TDTT Phường Sài Gòn 03',NULL,20,NULL,'Phường Sài Gòn, Thành phố Hồ Chí Minh','Đội của Trung tâm TDTT Phường Sài Gòn.',6,0.00,'HOAT_DONG','2026-05-22 13:39:43',NULL),(7,'Đội TDTT Phường Sài Gòn 04',NULL,20,NULL,'Phường Sài Gòn, Thành phố Hồ Chí Minh','Đội của Trung tâm TDTT Phường Sài Gòn.',7,0.00,'HOAT_DONG','2026-05-22 13:39:43',NULL),(8,'Đội TDTT TP.HCM 02',NULL,2,NULL,'Thành phố Hồ Chí Minh','Đội của Trung tâm huấn luyện và thi đấu TDTT Thành phố Hồ Chí Minh.',8,0.00,'HOAT_DONG','2026-05-22 13:39:43',NULL),(9,'Đội TDTT TP.HCM 03',NULL,2,NULL,'Thành phố Hồ Chí Minh','Đội của Trung tâm huấn luyện và thi đấu TDTT Thành phố Hồ Chí Minh.',9,0.00,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10,'Đội TDTT TP.HCM 04',NULL,2,NULL,'Thành phố Hồ Chí Minh','Đội của Trung tâm huấn luyện và thi đấu TDTT Thành phố Hồ Chí Minh.',10,0.00,'HOAT_DONG','2026-05-22 13:39:43',NULL),(11,'Đội TDTT Hà Nội 02',NULL,3,NULL,'Thành phố Hà Nội','Đội của Trung tâm huấn luyện và thi đấu TDTT Thành phố Hà Nội.',11,0.00,'HOAT_DONG','2026-05-22 13:39:43',NULL),(12,'Đội TDTT Hà Nội 03',NULL,3,NULL,'Thành phố Hà Nội','Đội của Trung tâm huấn luyện và thi đấu TDTT Thành phố Hà Nội.',12,0.00,'HOAT_DONG','2026-05-22 13:39:43',NULL),(13,'Đội TDTT Hà Nội 04',NULL,3,NULL,'Thành phố Hà Nội','Đội của Trung tâm huấn luyện và thi đấu TDTT Thành phố Hà Nội.',13,0.00,'HOAT_DONG','2026-05-22 13:39:43',NULL),(14,'Đội TDTT Phường Bến Thành 01',NULL,21,NULL,'Phường Bến Thành, Thành phố Hồ Chí Minh','Đội của Trung tâm TDTT Phường Bến Thành.',14,0.00,'HOAT_DONG','2026-05-22 13:39:43',NULL),(15,'Đội TDTT Phường Bến Thành 02',NULL,21,NULL,'Phường Bến Thành, Thành phố Hồ Chí Minh','Đội của Trung tâm TDTT Phường Bến Thành.',15,0.00,'HOAT_DONG','2026-05-22 13:39:43',NULL),(16,'Đội TDTT Phường Bến Thành 03',NULL,21,NULL,'Phường Bến Thành, Thành phố Hồ Chí Minh','Đội của Trung tâm TDTT Phường Bến Thành.',16,0.00,'HOAT_DONG','2026-05-22 13:39:43',NULL),(17,'Đội TDTT Phường Bến Thành 04',NULL,21,NULL,'Phường Bến Thành, Thành phố Hồ Chí Minh','Đội của Trung tâm TDTT Phường Bến Thành.',17,0.00,'HOAT_DONG','2026-05-22 13:39:43',NULL),(18,'Đội TDTT Phường Hoàn Kiếm 01',NULL,30,NULL,'Phường Hoàn Kiếm, Thành phố Hà Nội','Đội của Trung tâm TDTT Phường Hoàn Kiếm.',18,0.00,'HOAT_DONG','2026-05-22 13:39:43',NULL),(19,'Đội TDTT Phường Hoàn Kiếm 02',NULL,30,NULL,'Phường Hoàn Kiếm, Thành phố Hà Nội','Đội của Trung tâm TDTT Phường Hoàn Kiếm.',19,0.00,'HOAT_DONG','2026-05-22 13:39:43',NULL),(20,'Đội TDTT Phường Hoàn Kiếm 03',NULL,30,NULL,'Phường Hoàn Kiếm, Thành phố Hà Nội','Đội của Trung tâm TDTT Phường Hoàn Kiếm.',20,0.00,'HOAT_DONG','2026-05-22 13:39:43',NULL),(21,'Đội TDTT Phường Hoàn Kiếm 04',NULL,30,NULL,'Phường Hoàn Kiếm, Thành phố Hà Nội','Đội của Trung tâm TDTT Phường Hoàn Kiếm.',21,0.00,'HOAT_DONG','2026-05-22 13:39:43',NULL),(22,'Đội bóng Tư nhân Sài Gòn',NULL,20,NULL,'Phường Sài Gòn, Thành phố Hồ Chí Minh','Đội bóng tư nhân bên ngoài, có BTC đại diện tên đơn vị là Tư nhân.',22,0.00,'HOAT_DONG','2026-05-22 13:50:53',NULL),(23,'Đội bóng Tư nhân Bến Thành',NULL,21,NULL,'Phường Bến Thành, Thành phố Hồ Chí Minh','Đội bóng tư nhân trong Phường Bến Thành do HLV đại diện đăng ký giải.',23,0.00,'HOAT_DONG','2026-05-22 16:35:13',NULL),(24,'Đội bóng Tư nhân Hoàn Kiếm',NULL,30,NULL,'Phường Hoàn Kiếm, Thành phố Hà Nội','Đội bóng tư nhân trong Phường Hoàn Kiếm do HLV đại diện đăng ký giải.',24,0.00,'HOAT_DONG','2026-05-22 16:35:13',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=125 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doihinh`
--

LOCK TABLES `doihinh` WRITE;
/*!40000 ALTER TABLE `doihinh` DISABLE KEYS */;
INSERT INTO `doihinh` VALUES (101,1,NULL,'Đội hình nam chính','NAM',1,'DA_CHOT','2026-05-22 13:39:43',NULL),(102,2,NULL,'Đội hình nam chính','NAM',1,'DA_CHOT','2026-05-22 13:39:43',NULL),(103,3,NULL,'Đội hình nam chính','NAM',1,'DA_CHOT','2026-05-22 13:39:43',NULL),(104,4,NULL,'Đội hình nam chính','NAM',1,'DA_CHOT','2026-05-22 13:39:43',NULL),(105,5,NULL,'Đội hình nam chính','NAM',1,'DA_CHOT','2026-05-22 13:39:43',NULL),(106,6,NULL,'Đội hình nam chính','NAM',1,'DA_CHOT','2026-05-22 13:39:43',NULL),(107,7,NULL,'Đội hình nam chính','NAM',1,'DA_CHOT','2026-05-22 13:39:43',NULL),(108,8,NULL,'Đội hình nam chính','NAM',1,'DA_CHOT','2026-05-22 13:39:43',NULL),(109,9,NULL,'Đội hình nam chính','NAM',1,'DA_CHOT','2026-05-22 13:39:43',NULL),(110,10,NULL,'Đội hình nam chính','NAM',1,'DA_CHOT','2026-05-22 13:39:43',NULL),(111,11,NULL,'Đội hình nam chính','NAM',1,'DA_CHOT','2026-05-22 13:39:43',NULL),(112,12,NULL,'Đội hình nam chính','NAM',1,'DA_CHOT','2026-05-22 13:39:43',NULL),(113,13,NULL,'Đội hình nam chính','NAM',1,'DA_CHOT','2026-05-22 13:39:43',NULL),(114,14,NULL,'Đội hình nam chính','NAM',1,'DA_CHOT','2026-05-22 13:39:43',NULL),(115,15,NULL,'Đội hình nam chính','NAM',1,'DA_CHOT','2026-05-22 13:39:43',NULL),(116,16,NULL,'Đội hình nam chính','NAM',1,'DA_CHOT','2026-05-22 13:39:43',NULL),(117,17,NULL,'Đội hình nam chính','NAM',1,'DA_CHOT','2026-05-22 13:39:43',NULL),(118,18,NULL,'Đội hình nam chính','NAM',1,'DA_CHOT','2026-05-22 13:39:43',NULL),(119,19,NULL,'Đội hình nam chính','NAM',1,'DA_CHOT','2026-05-22 13:39:43',NULL),(120,20,NULL,'Đội hình nam chính','NAM',1,'DA_CHOT','2026-05-22 13:39:43',NULL),(121,21,NULL,'Đội hình nam chính','NAM',1,'DA_CHOT','2026-05-22 13:39:43',NULL),(122,22,NULL,'Đội hình nam chính','NAM',1,'DA_CHOT','2026-05-22 13:50:53',NULL),(123,23,NULL,'Đội hình nam chính','NAM',1,'DA_CHOT','2026-05-22 16:35:13',NULL),(124,24,NULL,'Đội hình nam chính','NAM',1,'DA_CHOT','2026-05-22 16:35:13',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doitrongvongdau`
--

LOCK TABLES `doitrongvongdau` WRITE;
/*!40000 ALTER TABLE `doitrongvongdau` DISABLE KEYS */;
INSERT INTO `doitrongvongdau` VALUES (22,13,1,1,NULL,'DANG_KY','HOP_LE','2026-05-22 17:08:45'),(23,13,2,2,NULL,'DANG_KY','HOP_LE','2026-05-22 17:08:45');
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
-- Table structure for table `donvi`
--

DROP TABLE IF EXISTS `donvi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `donvi` (
  `iddonvi` int(11) NOT NULL AUTO_INCREMENT,
  `madonvi` varchar(100) NOT NULL,
  `tendonvi` varchar(300) NOT NULL,
  `idloaidonvi` int(11) NOT NULL,
  `idkhuvuc` int(11) NOT NULL,
  `iddonvicha` int(11) DEFAULT NULL,
  `mota` varchar(1000) DEFAULT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'HOAT_DONG',
  `ngaytao` datetime NOT NULL DEFAULT current_timestamp(),
  `ngaycapnhat` datetime DEFAULT NULL,
  PRIMARY KEY (`iddonvi`),
  UNIQUE KEY `uq_donvi_ma` (`madonvi`),
  KEY `idx_donvi_loai` (`idloaidonvi`),
  KEY `idx_donvi_khuvuc` (`idkhuvuc`),
  KEY `idx_donvi_cha` (`iddonvicha`),
  CONSTRAINT `fk_donvi_cha` FOREIGN KEY (`iddonvicha`) REFERENCES `donvi` (`iddonvi`) ON UPDATE CASCADE,
  CONSTRAINT `fk_donvi_khuvuc` FOREIGN KEY (`idkhuvuc`) REFERENCES `khuvuc` (`idkhuvuc`) ON UPDATE CASCADE,
  CONSTRAINT `fk_donvi_loaidonvi` FOREIGN KEY (`idloaidonvi`) REFERENCES `loaidonvi` (`idloaidonvi`) ON UPDATE CASCADE,
  CONSTRAINT `chk_donvi_trangthai` CHECK (`trangthai` in ('HOAT_DONG','TAM_DUNG','NGUNG_SU_DUNG'))
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `donvi`
--

LOCK TABLES `donvi` WRITE;
/*!40000 ALTER TABLE `donvi` DISABLE KEYS */;
INSERT INTO `donvi` VALUES (1,'LDBCVN','Liên đoàn Bóng chuyền VN',1,1,NULL,'Đơn vị tổ chức giải cấp quốc gia.','HOAT_DONG','2026-05-22 10:33:15',NULL),(2,'SO_VHTT_TPHCM','Sở VH-TT Thành phố Hồ Chí Minh',2,2,1,'Đơn vị cấp tỉnh/thành có thẩm quyền tổ chức giải.','HOAT_DONG','2026-05-22 10:47:00',NULL),(3,'TT_HL_TDTT_TPHCM','Trung tâm huấn luyện và thi đấu TDTT Thành phố Hồ Chí Minh',3,2,2,'Đơn vị cấp tỉnh/thành có đội và BTC đại diện đăng ký thi đấu.','HOAT_DONG','2026-05-22 10:47:00',NULL),(4,'SO_VHTT_HANOI','Sở VH-TT Thành phố Hà Nội',2,3,1,'Đơn vị cấp tỉnh/thành có thẩm quyền tổ chức giải.','HOAT_DONG','2026-05-22 10:47:00',NULL),(5,'TT_HL_TDTT_HANOI','Trung tâm huấn luyện và thi đấu TDTT Thành phố Hà Nội',3,3,4,'Đơn vị cấp tỉnh/thành có đội và BTC đại diện đăng ký thi đấu.','HOAT_DONG','2026-05-22 10:47:00',NULL),(10,'TT_VHTT_PHUONG_SAI_GON','Trung tâm VH-TT Phường Sài Gòn',5,20,2,'Đơn vị cấp xã/phường có thẩm quyền tổ chức giải.','HOAT_DONG','2026-05-22 10:47:00',NULL),(11,'TT_TDTT_PHUONG_SAI_GON','Trung tâm TDTT Phường Sài Gòn',4,20,10,'Đơn vị cấp xã/phường có BTC đại diện đăng ký đội.','HOAT_DONG','2026-05-22 10:47:00',NULL),(12,'NVH_TN_PHUONG_SAI_GON','Nhà văn hóa thiếu nhi Phường Sài Gòn',6,20,10,'Đơn vị cấp xã/phường có BTC đại diện đăng ký đội.','HOAT_DONG','2026-05-22 10:47:00',NULL),(13,'TT_VHTT_PHUONG_BEN_THANH','Trung tâm VH-TT Phường Bến Thành',5,21,2,'Đơn vị cấp xã/phường có thẩm quyền tổ chức giải.','HOAT_DONG','2026-05-22 10:47:00',NULL),(14,'TT_VHTT_PHUONG_HOAN_KIEM','Trung tâm VH-TT Phường Hoàn Kiếm',5,30,4,'Đơn vị cấp xã/phường có thẩm quyền tổ chức giải.','HOAT_DONG','2026-05-22 10:47:00',NULL),(15,'TT_TDTT_PHUONG_BEN_THANH','Trung tâm TDTT Phường Bến Thành',4,21,13,'Đơn vị cấp xã/phường phụ trách tuyển chọn và đào tạo đội bóng tại Phường Bến Thành, Thành phố Hồ Chí Minh.','HOAT_DONG','2026-05-22 13:39:43',NULL),(16,'TT_TDTT_PHUONG_HOAN_KIEM','Trung tâm TDTT Phường Hoàn Kiếm',4,30,14,'Đơn vị cấp xã/phường phụ trách tuyển chọn và đào tạo đội bóng tại Phường Hoàn Kiếm, Thành phố Hà Nội.','HOAT_DONG','2026-05-22 13:39:43',NULL);
/*!40000 ALTER TABLE `donvi` ENABLE KEYS */;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_donvi_bi
BEFORE INSERT ON donvi
FOR EACH ROW
BEGIN
    DECLARE v_cap_loai VARCHAR(50);
    DECLARE v_cap_khuvuc VARCHAR(50);
    DECLARE v_loai_trangthai VARCHAR(50);

    SELECT macapapdung, trangthai
      INTO v_cap_loai, v_loai_trangthai
      FROM loaidonvi
     WHERE idloaidonvi = NEW.idloaidonvi;

    SELECT capkhuvuc
      INTO v_cap_khuvuc
      FROM khuvuc
     WHERE idkhuvuc = NEW.idkhuvuc;

    IF v_loai_trangthai <> 'HOAT_DONG' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Loai don vi phai dang hoat dong.';
    END IF;

    IF v_cap_loai <> v_cap_khuvuc THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Loai don vi khong khop cap khu vuc.';
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
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_donvi_bu
BEFORE UPDATE ON donvi
FOR EACH ROW
BEGIN
    DECLARE v_cap_loai VARCHAR(50);
    DECLARE v_cap_khuvuc VARCHAR(50);
    DECLARE v_loai_trangthai VARCHAR(50);

    SELECT macapapdung, trangthai
      INTO v_cap_loai, v_loai_trangthai
      FROM loaidonvi
     WHERE idloaidonvi = NEW.idloaidonvi;

    SELECT capkhuvuc
      INTO v_cap_khuvuc
      FROM khuvuc
     WHERE idkhuvuc = NEW.idkhuvuc;

    IF v_loai_trangthai <> 'HOAT_DONG' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Loai don vi phai dang hoat dong.';
    END IF;

    IF v_cap_loai <> v_cap_khuvuc THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Loai don vi khong khop cap khu vuc.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

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
  `thoigianbatdau` datetime NOT NULL,
  `thoigianketthuc` datetime NOT NULL,
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
  CONSTRAINT `chk_giaidau_thoigian` CHECK (`thoigianketthuc` > `thoigianbatdau`),
  CONSTRAINT `chk_giaidau_quymo` CHECK (`quymo` > 0),
  CONSTRAINT `chk_giaidau_tinhchat` CHECK (`tinhchat` in ('CHINH_THUC','GIAO_HUU','PHONG_TRAO','NOI_BO','MO_RONG')),
  CONSTRAINT `chk_giaidau_trangthai` CHECK (`trangthai` in ('NHAP','CHUA_CONG_BO','DA_CONG_BO','DANG_DIEN_RA','DA_KET_THUC','DA_HUY')),
  CONSTRAINT `chk_giaidau_dangky` CHECK (`trangthaidangky` in ('CHUA_MO','DANG_MO','DA_DONG')),
  CONSTRAINT `chk_giaidau_thietlap` CHECK (`trangthaithietlap` in ('DANG_THIET_LAP','DA_KHOA_DOI','DA_TAO_CAU_TRUC','DA_TAO_TRAN','DA_CONG_BO_LICH'))
) ENGINE=InnoDB AUTO_INCREMENT=110 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `giaidau`
--

LOCK TABLES `giaidau` WRITE;
/*!40000 ALTER TABLE `giaidau` DISABLE KEYS */;
INSERT INTO `giaidau` VALUES (101,'Giải Phường Sài Gòn 2026','Giải cấp xã/phường dùng để lọc đội tiềm năng.',3,20,3,2,'2026-04-01 00:00:00','2026-04-03 00:00:00',8,1,'Dữ liệu mẫu giải cấp xã/phường đã kết thúc.',NULL,NULL,NULL,'PHONG_TRAO','NAM','DA_KET_THUC','DA_DONG','DANG_THIET_LAP','Phường Sài Gòn','2026-05-22 10:47:00',NULL),(102,'Giải Thành phố Hồ Chí Minh 2026','Giải cấp tỉnh/thành xét các đội xã/phường đủ thành tích.',2,2,2,1,'2026-05-01 00:00:00','2026-05-05 00:00:00',8,1,'Dữ liệu mẫu giải cấp tỉnh/thành đã kết thúc.',NULL,NULL,NULL,'CHINH_THUC','NAM','DA_KET_THUC','DA_DONG','DANG_THIET_LAP','Thành phố Hồ Chí Minh','2026-05-22 10:47:00',NULL),(103,'Giải Quốc gia VTMS 2026','Giải cấp quốc gia nhận đội tỉnh/thành đủ điều kiện.',1,1,1,1,'2026-08-01 00:00:00','2026-08-07 00:00:00',16,1,'Dữ liệu mẫu giải quốc gia sắp diễn ra.',NULL,NULL,NULL,'CHINH_THUC','NAM','DA_CONG_BO','DANG_MO','DANG_THIET_LAP','Việt Nam','2026-05-22 10:47:00',NULL),(108,'Phuong Sai Gon 2026',NULL,3,20,3,1,'2026-05-22 15:30:00','2026-05-22 22:00:00',10,1,NULL,'/uploads/tournaments/tournament_20260522_144755_58accf37f2f0.jpg',NULL,NULL,'CHINH_THUC','NAM','DANG_DIEN_RA','DA_DONG','DANG_THIET_LAP',NULL,'2026-05-22 14:47:55','2026-05-22 15:41:54'),(109,'P.SaiGon 2026-ver2',NULL,3,20,3,1,'2026-05-22 17:10:00','2026-05-22 22:00:00',10,1,NULL,NULL,NULL,NULL,'CHINH_THUC','NAM','DANG_DIEN_RA','DA_DONG','DANG_THIET_LAP',NULL,'2026-05-22 16:40:56','2026-05-22 17:27:17');
/*!40000 ALTER TABLE `giaidau` ENABLE KEYS */;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_giaidau_bi
BEFORE INSERT ON giaidau
FOR EACH ROW
BEGIN
    DECLARE v_capphamvi VARCHAR(50);
    DECLARE v_capkv VARCHAR(50);
    DECLARE v_btc_cap INT;
    DECLARE v_btc_kv INT;
    DECLARE v_btc_donvi INT;
    DECLARE v_btc_status VARCHAR(50);
    DECLARE v_donvi_tochuc TINYINT(1);
    DECLARE v_count INT;

    SELECT capkhuvucphamvi
      INTO v_capphamvi
      FROM capgiaidau
     WHERE idcapgiaidau = NEW.idcapgiaidau;

    SELECT capkhuvuc
      INTO v_capkv
      FROM khuvuc
     WHERE idkhuvuc = NEW.idkhuvucphamvi;

    IF v_capphamvi <> v_capkv THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Khu vuc pham vi khong khop cap giai dau.';
    END IF;

    SELECT idcapbantochuc, idkhuvucquanly, iddonvi, trangthai
      INTO v_btc_cap, v_btc_kv, v_btc_donvi, v_btc_status
      FROM bantochuc
     WHERE idbantochuc = NEW.idbantochuc;

    IF v_btc_status <> 'HOAT_DONG' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'BTC phai hoat dong moi duoc tao giai.';
    END IF;

    IF v_btc_kv <> NEW.idkhuvucphamvi THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'BTC chi duoc tao giai trong khu vuc minh quan ly.';
    END IF;

    IF v_btc_donvi IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'BTC dai dien tu nhan khong duoc to chuc giai.';
    END IF;

    SELECT l.duoc_to_chuc_giai
      INTO v_donvi_tochuc
      FROM donvi d
      JOIN loaidonvi l ON l.idloaidonvi = d.idloaidonvi
     WHERE d.iddonvi = v_btc_donvi
       AND d.trangthai = 'HOAT_DONG'
       AND l.trangthai = 'HOAT_DONG';

    IF COALESCE(v_donvi_tochuc, 0) <> 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Don vi cua BTC khong co tham quyen to chuc giai.';
    END IF;

    SELECT COUNT(*)
      INTO v_count
      FROM quyencapbtc_capgiaidau
     WHERE idcapbantochuc = v_btc_cap
       AND idcapgiaidau = NEW.idcapgiaidau
       AND duoc_tao_giai = 1;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cap BTC khong co quyen tao cap giai dau nay.';
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
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_giaidau_bu
BEFORE UPDATE ON giaidau
FOR EACH ROW
BEGIN
    DECLARE v_capphamvi VARCHAR(50);
    DECLARE v_capkv VARCHAR(50);
    DECLARE v_btc_cap INT;
    DECLARE v_btc_kv INT;
    DECLARE v_btc_donvi INT;
    DECLARE v_btc_status VARCHAR(50);
    DECLARE v_donvi_tochuc TINYINT(1);
    DECLARE v_count INT;

    SELECT capkhuvucphamvi
      INTO v_capphamvi
      FROM capgiaidau
     WHERE idcapgiaidau = NEW.idcapgiaidau;

    SELECT capkhuvuc
      INTO v_capkv
      FROM khuvuc
     WHERE idkhuvuc = NEW.idkhuvucphamvi;

    IF v_capphamvi <> v_capkv THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Khu vuc pham vi khong khop cap giai dau.';
    END IF;

    SELECT idcapbantochuc, idkhuvucquanly, iddonvi, trangthai
      INTO v_btc_cap, v_btc_kv, v_btc_donvi, v_btc_status
      FROM bantochuc
     WHERE idbantochuc = NEW.idbantochuc;

    IF v_btc_status <> 'HOAT_DONG' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'BTC phai hoat dong moi duoc cap nhat giai.';
    END IF;

    IF v_btc_kv <> NEW.idkhuvucphamvi THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'BTC chi duoc quan ly giai trong khu vuc minh quan ly.';
    END IF;

    IF v_btc_donvi IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'BTC dai dien tu nhan khong duoc quan ly giai.';
    END IF;

    SELECT l.duoc_to_chuc_giai
      INTO v_donvi_tochuc
      FROM donvi d
      JOIN loaidonvi l ON l.idloaidonvi = d.idloaidonvi
     WHERE d.iddonvi = v_btc_donvi
       AND d.trangthai = 'HOAT_DONG'
       AND l.trangthai = 'HOAT_DONG';

    IF COALESCE(v_donvi_tochuc, 0) <> 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Don vi cua BTC khong co tham quyen quan ly giai.';
    END IF;

    SELECT COUNT(*)
      INTO v_count
      FROM quyencapbtc_capgiaidau
     WHERE idcapbantochuc = v_btc_cap
       AND idcapgiaidau = NEW.idcapgiaidau
       AND duoc_quan_ly = 1;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cap BTC khong co quyen quan ly cap giai dau nay.';
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
  `iddonvi` int(11) DEFAULT NULL,
  `la_hlv_tu_nhan` tinyint(1) NOT NULL DEFAULT 0,
  `donvicongtac` varchar(300) DEFAULT NULL,
  `bangcap` varchar(300) DEFAULT NULL,
  `kinhnghiem` int(11) NOT NULL DEFAULT 0,
  `trangthai` varchar(50) NOT NULL DEFAULT 'CHO_DUYET',
  PRIMARY KEY (`idhuanluyenvien`),
  UNIQUE KEY `idnguoidung` (`idnguoidung`),
  KEY `idx_hlv_khuvuccongtac` (`idkhuvuccongtac`),
  KEY `idx_hlv_donvi` (`iddonvi`),
  CONSTRAINT `fk_hlv_donvi` FOREIGN KEY (`iddonvi`) REFERENCES `donvi` (`iddonvi`) ON UPDATE CASCADE,
  CONSTRAINT `fk_hlv_khuvuccongtac` FOREIGN KEY (`idkhuvuccongtac`) REFERENCES `khuvuc` (`idkhuvuc`) ON UPDATE CASCADE,
  CONSTRAINT `fk_hlv_nguoidung` FOREIGN KEY (`idnguoidung`) REFERENCES `nguoidung` (`idnguoidung`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_hlv_kinhnghiem` CHECK (`kinhnghiem` >= 0),
  CONSTRAINT `chk_hlv_trangthai` CHECK (`trangthai` in ('CHO_DUYET','DA_XAC_NHAN','BI_HUY_TU_CACH','NGUNG_HOAT_DONG')),
  CONSTRAINT `chk_hlv_tu_nhan` CHECK (`la_hlv_tu_nhan` in (0,1))
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `huanluyenvien`
--

LOCK TABLES `huanluyenvien` WRITE;
/*!40000 ALTER TABLE `huanluyenvien` DISABLE KEYS */;
INSERT INTO `huanluyenvien` VALUES (1,6,20,11,0,'Trung tâm TDTT Phường Sài Gòn','Chứng chỉ HLV cơ sở',4,'DA_XAC_NHAN'),(2,7,20,NULL,1,'HLV tư nhân Phường Sài Gòn','Chứng chỉ HLV phong trào',3,'DA_XAC_NHAN'),(3,8,2,3,0,'Trung tâm huấn luyện và thi đấu TDTT Thành phố Hồ Chí Minh','Chứng chỉ HLV cấp tỉnh',8,'DA_XAC_NHAN'),(4,9,3,5,0,'Trung tâm huấn luyện và thi đấu TDTT Thành phố Hà Nội','Chứng chỉ HLV cấp tỉnh',7,'DA_XAC_NHAN'),(5,20,20,11,0,'Trung tâm TDTT Phường Sài Gòn','Chứng chỉ huấn luyện bóng chuyền',4,'DA_XAC_NHAN'),(6,21,20,11,0,'Trung tâm TDTT Phường Sài Gòn','Chứng chỉ huấn luyện bóng chuyền',5,'DA_XAC_NHAN'),(7,22,20,11,0,'Trung tâm TDTT Phường Sài Gòn','Chứng chỉ huấn luyện bóng chuyền',6,'DA_XAC_NHAN'),(8,23,2,3,0,'Trung tâm huấn luyện và thi đấu TDTT Thành phố Hồ Chí Minh','Chứng chỉ huấn luyện bóng chuyền',8,'DA_XAC_NHAN'),(9,24,2,3,0,'Trung tâm huấn luyện và thi đấu TDTT Thành phố Hồ Chí Minh','Chứng chỉ huấn luyện bóng chuyền',9,'DA_XAC_NHAN'),(10,25,2,3,0,'Trung tâm huấn luyện và thi đấu TDTT Thành phố Hồ Chí Minh','Chứng chỉ huấn luyện bóng chuyền',10,'DA_XAC_NHAN'),(11,26,3,5,0,'Trung tâm huấn luyện và thi đấu TDTT Thành phố Hà Nội','Chứng chỉ huấn luyện bóng chuyền',8,'DA_XAC_NHAN'),(12,27,3,5,0,'Trung tâm huấn luyện và thi đấu TDTT Thành phố Hà Nội','Chứng chỉ huấn luyện bóng chuyền',9,'DA_XAC_NHAN'),(13,28,3,5,0,'Trung tâm huấn luyện và thi đấu TDTT Thành phố Hà Nội','Chứng chỉ huấn luyện bóng chuyền',10,'DA_XAC_NHAN'),(14,29,21,15,0,'Trung tâm TDTT Phường Bến Thành','Chứng chỉ huấn luyện bóng chuyền',3,'DA_XAC_NHAN'),(15,30,21,15,0,'Trung tâm TDTT Phường Bến Thành','Chứng chỉ huấn luyện bóng chuyền',4,'DA_XAC_NHAN'),(16,31,21,15,0,'Trung tâm TDTT Phường Bến Thành','Chứng chỉ huấn luyện bóng chuyền',5,'DA_XAC_NHAN'),(17,32,21,15,0,'Trung tâm TDTT Phường Bến Thành','Chứng chỉ huấn luyện bóng chuyền',6,'DA_XAC_NHAN'),(18,33,30,16,0,'Trung tâm TDTT Phường Hoàn Kiếm','Chứng chỉ huấn luyện bóng chuyền',3,'DA_XAC_NHAN'),(19,34,30,16,0,'Trung tâm TDTT Phường Hoàn Kiếm','Chứng chỉ huấn luyện bóng chuyền',4,'DA_XAC_NHAN'),(20,35,30,16,0,'Trung tâm TDTT Phường Hoàn Kiếm','Chứng chỉ huấn luyện bóng chuyền',5,'DA_XAC_NHAN'),(21,36,30,16,0,'Trung tâm TDTT Phường Hoàn Kiếm','Chứng chỉ huấn luyện bóng chuyền',6,'DA_XAC_NHAN'),(22,37,20,NULL,1,'Tư nhân','Chứng chỉ huấn luyện bóng chuyền phong trào',5,'DA_XAC_NHAN'),(23,38,21,NULL,1,'Tư nhân','Chứng chỉ huấn luyện bóng chuyền phong trào',4,'DA_XAC_NHAN'),(24,39,30,NULL,1,'Tư nhân','Chứng chỉ huấn luyện bóng chuyền phong trào',4,'DA_XAC_NHAN');
/*!40000 ALTER TABLE `huanluyenvien` ENABLE KEYS */;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_huanluyenvien_bi
BEFORE INSERT ON huanluyenvien
FOR EACH ROW
BEGIN
    DECLARE v_donvi_khuvuc INT;
    DECLARE v_donvi_trangthai VARCHAR(50);
    DECLARE v_la_cap_thap_nhat TINYINT(1);

    IF NEW.iddonvi IS NULL THEN
        IF NEW.la_hlv_tu_nhan <> 1 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'HLV khong tu nhan phai thuoc mot don vi.';
        END IF;

        IF NEW.idkhuvuccongtac IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'HLV tu nhan phai co khu vuc cong tac.';
        END IF;

        SELECT cq.la_cap_thap_nhat
          INTO v_la_cap_thap_nhat
          FROM khuvuc k
          JOIN capchinhquyen cq ON cq.macap = k.capkhuvuc
         WHERE k.idkhuvuc = NEW.idkhuvuccongtac;

        IF v_la_cap_thap_nhat <> 1 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'HLV tu nhan chi duoc o cap thap nhat.';
        END IF;
    ELSE
        IF NEW.la_hlv_tu_nhan <> 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'HLV thuoc don vi khong duoc danh dau tu nhan.';
        END IF;

        SELECT idkhuvuc, trangthai
          INTO v_donvi_khuvuc, v_donvi_trangthai
          FROM donvi
         WHERE iddonvi = NEW.iddonvi;

        IF v_donvi_trangthai <> 'HOAT_DONG' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Don vi cua HLV phai dang hoat dong.';
        END IF;

        IF NEW.idkhuvuccongtac IS NULL OR NEW.idkhuvuccongtac <> v_donvi_khuvuc THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Khu vuc cong tac cua HLV phai khop don vi.';
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
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_huanluyenvien_bu
BEFORE UPDATE ON huanluyenvien
FOR EACH ROW
BEGIN
    DECLARE v_donvi_khuvuc INT;
    DECLARE v_donvi_trangthai VARCHAR(50);
    DECLARE v_la_cap_thap_nhat TINYINT(1);

    IF NEW.iddonvi IS NULL THEN
        IF NEW.la_hlv_tu_nhan <> 1 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'HLV khong tu nhan phai thuoc mot don vi.';
        END IF;

        IF NEW.idkhuvuccongtac IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'HLV tu nhan phai co khu vuc cong tac.';
        END IF;

        SELECT cq.la_cap_thap_nhat
          INTO v_la_cap_thap_nhat
          FROM khuvuc k
          JOIN capchinhquyen cq ON cq.macap = k.capkhuvuc
         WHERE k.idkhuvuc = NEW.idkhuvuccongtac;

        IF v_la_cap_thap_nhat <> 1 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'HLV tu nhan chi duoc o cap thap nhat.';
        END IF;
    ELSE
        IF NEW.la_hlv_tu_nhan <> 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'HLV thuoc don vi khong duoc danh dau tu nhan.';
        END IF;

        SELECT idkhuvuc, trangthai
          INTO v_donvi_khuvuc, v_donvi_trangthai
          FROM donvi
         WHERE iddonvi = NEW.iddonvi;

        IF v_donvi_trangthai <> 'HOAT_DONG' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Don vi cua HLV phai dang hoat dong.';
        END IF;

        IF NEW.idkhuvuccongtac IS NULL OR NEW.idkhuvuccongtac <> v_donvi_khuvuc THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Khu vuc cong tac cua HLV phai khop don vi.';
        END IF;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

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
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ketquatrandau`
--

LOCK TABLES `ketquatrandau` WRITE;
/*!40000 ALTER TABLE `ketquatrandau` DISABLE KEYS */;
INSERT INTO `ketquatrandau` VALUES (13,20,1,2,51,45,3,0,'CHO_CONG_BO','2026-05-22 17:14:30',NULL,42);
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
  CONSTRAINT `fk_khuvuc_capchinhquyen` FOREIGN KEY (`capkhuvuc`) REFERENCES `capchinhquyen` (`macap`) ON UPDATE CASCADE,
  CONSTRAINT `fk_khuvuc_cha` FOREIGN KEY (`idkhuvuccha`) REFERENCES `khuvuc` (`idkhuvuc`) ON UPDATE CASCADE,
  CONSTRAINT `chk_khuvuc_trangthai` CHECK (`trangthai` in ('HOAT_DONG','NGUNG_SU_DUNG'))
) ENGINE=InnoDB AUTO_INCREMENT=1033 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `khuvuc`
--

LOCK TABLES `khuvuc` WRITE;
/*!40000 ALTER TABLE `khuvuc` DISABLE KEYS */;
INSERT INTO `khuvuc` VALUES (1,'VN','Việt Nam','QUOC_GIA',NULL,'Phạm vi quốc gia gốc để nhập dữ liệu tỉnh/thành.','HOAT_DONG','2026-05-22 10:33:15',NULL),(2,'TP_HCM','Thành phố Hồ Chí Minh','TINH_THANH',1,'Tỉnh/thành trực thuộc phạm vi Việt Nam trong dữ liệu mẫu mới.','HOAT_DONG','2026-05-22 10:47:00',NULL),(3,'HA_NOI','Thành phố Hà Nội','TINH_THANH',1,'Tỉnh/thành trực thuộc phạm vi Việt Nam trong dữ liệu mẫu mới.','HOAT_DONG','2026-05-22 10:47:00',NULL),(20,'PHUONG_SAI_GON','Phường Sài Gòn','XA_PHUONG',2,'Xã/phường mới có thể đại diện cho nhiều phường cũ đã gộp.','HOAT_DONG','2026-05-22 10:47:00',NULL),(21,'PHUONG_BEN_THANH','Phường Bến Thành','XA_PHUONG',2,'Xã/phường cấp thấp nhất trong mô hình quản lý mới.','HOAT_DONG','2026-05-22 10:47:00',NULL),(30,'PHUONG_HOAN_KIEM','Phường Hoàn Kiếm','XA_PHUONG',3,'Xã/phường trực thuộc tỉnh/thành, không qua cấp quận.','HOAT_DONG','2026-05-22 10:47:00',NULL);
/*!40000 ALTER TABLE `khuvuc` ENABLE KEYS */;
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
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_khuvuc_bi
BEFORE INSERT ON khuvuc
FOR EACH ROW
BEGIN
    DECLARE v_capcha_yeucau VARCHAR(50);
    DECLARE v_capcha_thucte VARCHAR(50);
    DECLARE v_cap_trangthai VARCHAR(50);

    SET v_capcha_yeucau = NULL;
    SET v_capcha_thucte = NULL;
    SET v_cap_trangthai = NULL;

    SELECT macapcha, trangthai
      INTO v_capcha_yeucau, v_cap_trangthai
      FROM capchinhquyen
     WHERE macap = NEW.capkhuvuc;

    IF v_cap_trangthai <> 'HOAT_DONG' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cap khu vuc phai dang hoat dong.';
    END IF;

    IF v_capcha_yeucau IS NULL THEN
        IF NEW.idkhuvuccha IS NOT NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Cap goc khong duoc co khu vuc cha.';
        END IF;
    ELSE
        IF NEW.idkhuvuccha IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Khu vuc cap con phai co khu vuc cha.';
        END IF;

        SELECT capkhuvuc
          INTO v_capcha_thucte
          FROM khuvuc
         WHERE idkhuvuc = NEW.idkhuvuccha;

        IF v_capcha_thucte <> v_capcha_yeucau THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Cap khu vuc cha khong dung cap duoc khai bao.';
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
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_khuvuc_bu
BEFORE UPDATE ON khuvuc
FOR EACH ROW
BEGIN
    DECLARE v_capcha_yeucau VARCHAR(50);
    DECLARE v_capcha_thucte VARCHAR(50);
    DECLARE v_cap_trangthai VARCHAR(50);

    SET v_capcha_yeucau = NULL;
    SET v_capcha_thucte = NULL;
    SET v_cap_trangthai = NULL;

    SELECT macapcha, trangthai
      INTO v_capcha_yeucau, v_cap_trangthai
      FROM capchinhquyen
     WHERE macap = NEW.capkhuvuc;

    IF v_cap_trangthai <> 'HOAT_DONG' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cap khu vuc phai dang hoat dong.';
    END IF;

    IF v_capcha_yeucau IS NULL THEN
        IF NEW.idkhuvuccha IS NOT NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Cap goc khong duoc co khu vuc cha.';
        END IF;
    ELSE
        IF NEW.idkhuvuccha IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Khu vuc cap con phai co khu vuc cha.';
        END IF;

        SELECT capkhuvuc
          INTO v_capcha_thucte
          FROM khuvuc
         WHERE idkhuvuc = NEW.idkhuvuccha;

        IF v_capcha_thucte <> v_capcha_yeucau THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Cap khu vuc cha khong dung cap duoc khai bao.';
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
) ENGINE=InnoDB AUTO_INCREMENT=81 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lichsudangnhap`
--

LOCK TABLES `lichsudangnhap` WRITE;
/*!40000 ALTER TABLE `lichsudangnhap` DISABLE KEYS */;
INSERT INTO `lichsudangnhap` VALUES (71,4,'2026-05-22 13:57:22','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36 Edg/148.0.0.0','THANH_CONG','Dang nhap thanh cong'),(72,5,'2026-05-22 14:48:41','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','THANH_CONG','Dang nhap thanh cong'),(73,20,'2026-05-22 14:54:50','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','THANH_CONG','Dang nhap thanh cong'),(74,21,'2026-05-22 16:01:39','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','THANH_CONG','Dang nhap thanh cong'),(75,6,'2026-05-22 16:41:51','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','THANH_CONG','Dang nhap thanh cong'),(76,7,'2026-05-22 16:42:24','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','THANH_CONG','Dang nhap thanh cong'),(77,6,'2026-05-22 16:45:00','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','THANH_CONG','Dang nhap thanh cong'),(78,4,'2026-05-22 16:50:04','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36 Edg/148.0.0.0','THANH_CONG','Dang nhap thanh cong'),(79,42,'2026-05-22 17:10:18','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','THANH_CONG','Dang nhap thanh cong'),(80,3,'2026-05-22 22:21:39','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','THANH_CONG','Dang nhap thanh cong');
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
/*!40000 ALTER TABLE `lichsuthanhviendoibong` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `loaidonvi`
--

DROP TABLE IF EXISTS `loaidonvi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `loaidonvi` (
  `idloaidonvi` int(11) NOT NULL AUTO_INCREMENT,
  `maloaidonvi` varchar(100) NOT NULL,
  `tenloaidonvi` varchar(300) NOT NULL,
  `macapapdung` varchar(50) NOT NULL,
  `duoc_to_chuc_giai` tinyint(1) NOT NULL DEFAULT 0,
  `mota` varchar(1000) DEFAULT NULL,
  `trangthai` varchar(50) NOT NULL DEFAULT 'HOAT_DONG',
  PRIMARY KEY (`idloaidonvi`),
  UNIQUE KEY `uq_loaidonvi_ma` (`maloaidonvi`),
  KEY `idx_loaidonvi_cap` (`macapapdung`),
  CONSTRAINT `fk_loaidonvi_capchinhquyen` FOREIGN KEY (`macapapdung`) REFERENCES `capchinhquyen` (`macap`) ON UPDATE CASCADE,
  CONSTRAINT `chk_loaidonvi_tochuc` CHECK (`duoc_to_chuc_giai` in (0,1)),
  CONSTRAINT `chk_loaidonvi_trangthai` CHECK (`trangthai` in ('HOAT_DONG','NGUNG_SU_DUNG'))
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `loaidonvi`
--

LOCK TABLES `loaidonvi` WRITE;
/*!40000 ALTER TABLE `loaidonvi` DISABLE KEYS */;
INSERT INTO `loaidonvi` VALUES (1,'LIEN_DOAN_BONG_CHUYEN_VN','Liên đoàn Bóng chuyền VN','QUOC_GIA',1,'Đơn vị cấp quốc gia có thẩm quyền tổ chức giải.','HOAT_DONG'),(2,'SO_VH_TT_TINH','Sở VH-TT các tỉnh','TINH_THANH',1,'Đơn vị cấp tỉnh/thành có thẩm quyền tổ chức giải.','HOAT_DONG'),(3,'TRUNG_TAM_HL_TDTT_TINH','Trung tâm huấn luyện và thi đấu TDTT tỉnh','TINH_THANH',0,'Đơn vị cấp tỉnh/thành có BTC đại diện đăng ký đội.','HOAT_DONG'),(4,'TRUNG_TAM_TDTT_XA_PHUONG','Trung tâm TDTT Phường/xã','XA_PHUONG',0,'Đơn vị cấp xã/phường có BTC đại diện đăng ký đội.','HOAT_DONG'),(5,'TRUNG_TAM_VH_TT_XA_PHUONG','Trung tâm VH-TT Phường/xã','XA_PHUONG',1,'Đơn vị cấp xã/phường có thẩm quyền tổ chức giải.','HOAT_DONG'),(6,'NHA_VAN_HOA_THIEU_NHI_XA_PHUONG','Nhà văn hóa thiếu nhi','XA_PHUONG',0,'Đơn vị cấp xã/phường có BTC đại diện đăng ký đội.','HOAT_DONG');
/*!40000 ALTER TABLE `loaidonvi` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=10247 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nguoidung`
--

LOCK TABLES `nguoidung` WRITE;
/*!40000 ALTER TABLE `nguoidung` DISABLE KEYS */;
INSERT INTO `nguoidung` VALUES (1,1,'Admin','VTMS','NAM','1990-01-01','Việt Nam','Hệ thống VTMS',NULL,'001000000001','2026-05-22 10:47:00',NULL),(2,2,'Quốc Gia','BTC','NAM','1985-02-01','Việt Nam','Liên đoàn Bóng chuyền VN',NULL,'001000000002','2026-05-22 10:47:00',NULL),(3,3,'Hồ Chí Minh','BTC','NU','1988-03-01','Thành phố Hồ Chí Minh','Sở VH-TT Thành phố Hồ Chí Minh',NULL,'001000000003','2026-05-22 10:47:00',NULL),(4,4,'Sài Gòn','BTC Phường','NAM','1987-04-01','Thành phố Hồ Chí Minh','Trung tâm VH-TT Phường Sài Gòn',NULL,'001000000004','2026-05-22 10:47:00',NULL),(5,5,'Đại diện','BTC Trung tâm TDTT','NU','1989-05-01','Phường Sài Gòn','Trung tâm TDTT Phường Sài Gòn',NULL,'001000000005','2026-05-22 10:47:00',NULL),(6,6,'Trung tâm Sài Gòn','HLV','NAM','1981-08-01','Phường Sài Gòn','Trung tâm TDTT Phường Sài Gòn',NULL,'001000000006','2026-05-22 10:47:00',NULL),(7,7,'Tư nhân Sài Gòn','HLV','NAM','1983-09-01','Phường Sài Gòn','Phường Sài Gòn',NULL,'001000000007','2026-05-22 10:47:00',NULL),(8,8,'Đội tuyển TP.HCM','HLV','NU','1984-10-01','Thành phố Hồ Chí Minh','Trung tâm HL và thi đấu TDTT TP.HCM',NULL,'001000000008','2026-05-22 10:47:00',NULL),(9,9,'Đội tuyển Hà Nội','HLV','NAM','1986-11-01','Thành phố Hà Nội','Trung tâm HL và thi đấu TDTT Hà Nội',NULL,'001000000009','2026-05-22 10:47:00',NULL),(10,10,'TP.HCM','BTC TDTT','NAM','1984-01-10','Thành phố Hồ Chí Minh','Trung tâm huấn luyện và thi đấu TDTT Thành phố Hồ Chí Minh',NULL,'001000000010','2026-05-22 13:39:43',NULL),(11,11,'Hà Nội','BTC TDTT','NAM','1984-01-11','Thành phố Hà Nội','Trung tâm huấn luyện và thi đấu TDTT Thành phố Hà Nội',NULL,'001000000011','2026-05-22 13:39:43',NULL),(12,12,'Bến Thành','BTC TDTT Phường','NAM','1984-01-12','Phường Bến Thành','Trung tâm TDTT Phường Bến Thành',NULL,'001000000012','2026-05-22 13:39:43',NULL),(13,13,'Hoàn Kiếm','BTC TDTT Phường','NAM','1984-01-13','Phường Hoàn Kiếm','Trung tâm TDTT Phường Hoàn Kiếm',NULL,'001000000013','2026-05-22 13:39:43',NULL),(14,14,'Hà Nội','BTC VH-TT','NU','1984-01-14','Thành phố Hà Nội','Sở VH-TT Thành phố Hà Nội',NULL,'001000000014','2026-05-22 13:39:43',NULL),(15,15,'Bến Thành','BTC VH-TT Phường','NU','1984-01-15','Phường Bến Thành','Trung tâm VH-TT Phường Bến Thành',NULL,'001000000015','2026-05-22 13:39:43',NULL),(16,16,'Hoàn Kiếm','BTC VH-TT Phường','NU','1984-01-16','Phường Hoàn Kiếm','Trung tâm VH-TT Phường Hoàn Kiếm',NULL,'001000000016','2026-05-22 13:39:43',NULL),(17,17,'Tư nhân Sài Gòn','BTC Đại diện','NAM','1984-01-17','Phường Sài Gòn','Tư nhân',NULL,'001000000017','2026-05-22 13:50:53',NULL),(20,20,'Sài Gòn 02','HLV TDTT Phường','NAM','1988-01-01','Trung tâm TDTT Phường Sài Gòn','Trung tâm TDTT Phường Sài Gòn',NULL,'001000000020','2026-05-22 13:39:43',NULL),(21,21,'Sài Gòn 03','HLV TDTT Phường','NAM','1988-01-01','Trung tâm TDTT Phường Sài Gòn','Trung tâm TDTT Phường Sài Gòn',NULL,'001000000021','2026-05-22 13:39:43',NULL),(22,22,'Sài Gòn 04','HLV TDTT Phường','NAM','1988-01-01','Trung tâm TDTT Phường Sài Gòn','Trung tâm TDTT Phường Sài Gòn',NULL,'001000000022','2026-05-22 13:39:43',NULL),(23,23,'TP.HCM 02','HLV TDTT Thành phố','NAM','1988-01-01','Trung tâm huấn luyện và thi đấu TDTT Thành phố Hồ Chí Minh','Trung tâm huấn luyện và thi đấu TDTT Thành phố Hồ Chí Minh',NULL,'001000000023','2026-05-22 13:39:43',NULL),(24,24,'TP.HCM 03','HLV TDTT Thành phố','NAM','1988-01-01','Trung tâm huấn luyện và thi đấu TDTT Thành phố Hồ Chí Minh','Trung tâm huấn luyện và thi đấu TDTT Thành phố Hồ Chí Minh',NULL,'001000000024','2026-05-22 13:39:43',NULL),(25,25,'TP.HCM 04','HLV TDTT Thành phố','NAM','1988-01-01','Trung tâm huấn luyện và thi đấu TDTT Thành phố Hồ Chí Minh','Trung tâm huấn luyện và thi đấu TDTT Thành phố Hồ Chí Minh',NULL,'001000000025','2026-05-22 13:39:43',NULL),(26,26,'Hà Nội 02','HLV TDTT Thành phố','NAM','1988-01-01','Trung tâm huấn luyện và thi đấu TDTT Thành phố Hà Nội','Trung tâm huấn luyện và thi đấu TDTT Thành phố Hà Nội',NULL,'001000000026','2026-05-22 13:39:43',NULL),(27,27,'Hà Nội 03','HLV TDTT Thành phố','NAM','1988-01-01','Trung tâm huấn luyện và thi đấu TDTT Thành phố Hà Nội','Trung tâm huấn luyện và thi đấu TDTT Thành phố Hà Nội',NULL,'001000000027','2026-05-22 13:39:43',NULL),(28,28,'Hà Nội 04','HLV TDTT Thành phố','NAM','1988-01-01','Trung tâm huấn luyện và thi đấu TDTT Thành phố Hà Nội','Trung tâm huấn luyện và thi đấu TDTT Thành phố Hà Nội',NULL,'001000000028','2026-05-22 13:39:43',NULL),(29,29,'Bến Thành 01','HLV TDTT Phường','NAM','1988-01-01','Trung tâm TDTT Phường Bến Thành','Trung tâm TDTT Phường Bến Thành',NULL,'001000000029','2026-05-22 13:39:43',NULL),(30,30,'Bến Thành 02','HLV TDTT Phường','NAM','1988-01-01','Trung tâm TDTT Phường Bến Thành','Trung tâm TDTT Phường Bến Thành',NULL,'001000000030','2026-05-22 13:39:43',NULL),(31,31,'Bến Thành 03','HLV TDTT Phường','NAM','1988-01-01','Trung tâm TDTT Phường Bến Thành','Trung tâm TDTT Phường Bến Thành',NULL,'001000000031','2026-05-22 13:39:43',NULL),(32,32,'Bến Thành 04','HLV TDTT Phường','NAM','1988-01-01','Trung tâm TDTT Phường Bến Thành','Trung tâm TDTT Phường Bến Thành',NULL,'001000000032','2026-05-22 13:39:43',NULL),(33,33,'Hoàn Kiếm 01','HLV TDTT Phường','NAM','1988-01-01','Trung tâm TDTT Phường Hoàn Kiếm','Trung tâm TDTT Phường Hoàn Kiếm',NULL,'001000000033','2026-05-22 13:39:43',NULL),(34,34,'Hoàn Kiếm 02','HLV TDTT Phường','NAM','1988-01-01','Trung tâm TDTT Phường Hoàn Kiếm','Trung tâm TDTT Phường Hoàn Kiếm',NULL,'001000000034','2026-05-22 13:39:43',NULL),(35,35,'Hoàn Kiếm 03','HLV TDTT Phường','NAM','1988-01-01','Trung tâm TDTT Phường Hoàn Kiếm','Trung tâm TDTT Phường Hoàn Kiếm',NULL,'001000000035','2026-05-22 13:39:43',NULL),(36,36,'Hoàn Kiếm 04','HLV TDTT Phường','NAM','1988-01-01','Trung tâm TDTT Phường Hoàn Kiếm','Trung tâm TDTT Phường Hoàn Kiếm',NULL,'001000000036','2026-05-22 13:39:43',NULL),(37,37,'Tư nhân Ngoài Sài Gòn','HLV','NAM','1988-01-02','Phường Sài Gòn','Tư nhân',NULL,'001000000037','2026-05-22 13:50:53',NULL),(38,38,'Tư nhân Bến Thành','HLV','NAM','1988-01-03','Phường Bến Thành','Tư nhân',NULL,'001000000038','2026-05-22 16:35:13',NULL),(39,39,'Tư nhân Hoàn Kiếm','HLV','NAM','1988-01-03','Phường Hoàn Kiếm','Tư nhân',NULL,'001000000039','2026-05-22 16:35:13',NULL),(40,40,'Sài Gòn 01','Trọng tài Phường','NAM','1986-01-10','Phường Sài Gòn','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'001000000040','2026-05-22 16:58:22',NULL),(41,41,'Sài Gòn 02','Trọng tài Phường','NU','1988-02-11','Phường Sài Gòn','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'001000000041','2026-05-22 16:58:22',NULL),(42,42,'Sài Gòn 03','Trọng tài Phường','NAM','1990-03-12','Phường Sài Gòn','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'001000000042','2026-05-22 16:58:22',NULL),(43,43,'Bến Thành 01','Trọng tài Phường','NAM','1987-04-13','Phường Bến Thành','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'001000000043','2026-05-22 16:58:22',NULL),(44,44,'Bến Thành 02','Trọng tài Phường','NU','1989-05-14','Phường Bến Thành','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'001000000044','2026-05-22 16:58:22',NULL),(45,45,'Bến Thành 03','Trọng tài Phường','NAM','1991-06-15','Phường Bến Thành','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'001000000045','2026-05-22 16:58:22',NULL),(46,46,'Hoàn Kiếm 01','Trọng tài Phường','NAM','1986-07-16','Phường Hoàn Kiếm','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'001000000046','2026-05-22 16:58:22',NULL),(47,47,'Hoàn Kiếm 02','Trọng tài Phường','NU','1988-08-17','Phường Hoàn Kiếm','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'001000000047','2026-05-22 16:58:22',NULL),(48,48,'Hoàn Kiếm 03','Trọng tài Phường','NAM','1990-09-18','Phường Hoàn Kiếm','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'001000000048','2026-05-22 16:58:22',NULL),(10011,10011,'Nam 01','VĐV đội 01','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV000101','2026-05-22 13:39:43',NULL),(10012,10012,'Nam 02','VĐV đội 01','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV000102','2026-05-22 13:39:43',NULL),(10013,10013,'Nam 03','VĐV đội 01','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV000103','2026-05-22 13:39:43',NULL),(10014,10014,'Nam 04','VĐV đội 01','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV000104','2026-05-22 13:39:43',NULL),(10015,10015,'Nam 05','VĐV đội 01','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV000105','2026-05-22 13:39:43',NULL),(10016,10016,'Nam 06','VĐV đội 01','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV000106','2026-05-22 13:39:43',NULL),(10021,10021,'Nam 01','VĐV đội 02','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV000201','2026-05-22 13:39:43',NULL),(10022,10022,'Nam 02','VĐV đội 02','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV000202','2026-05-22 13:39:43',NULL),(10023,10023,'Nam 03','VĐV đội 02','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV000203','2026-05-22 13:39:43',NULL),(10024,10024,'Nam 04','VĐV đội 02','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV000204','2026-05-22 13:39:43',NULL),(10025,10025,'Nam 05','VĐV đội 02','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV000205','2026-05-22 13:39:43',NULL),(10026,10026,'Nam 06','VĐV đội 02','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV000206','2026-05-22 13:39:43',NULL),(10031,10031,'Nam 01','VĐV đội 03','NAM','2004-01-01','Thành phố Hồ Chí Minh','Thành phố Hồ Chí Minh',NULL,'VDV000301','2026-05-22 13:39:43',NULL),(10032,10032,'Nam 02','VĐV đội 03','NAM','2004-01-01','Thành phố Hồ Chí Minh','Thành phố Hồ Chí Minh',NULL,'VDV000302','2026-05-22 13:39:43',NULL),(10033,10033,'Nam 03','VĐV đội 03','NAM','2004-01-01','Thành phố Hồ Chí Minh','Thành phố Hồ Chí Minh',NULL,'VDV000303','2026-05-22 13:39:43',NULL),(10034,10034,'Nam 04','VĐV đội 03','NAM','2004-01-01','Thành phố Hồ Chí Minh','Thành phố Hồ Chí Minh',NULL,'VDV000304','2026-05-22 13:39:43',NULL),(10035,10035,'Nam 05','VĐV đội 03','NAM','2004-01-01','Thành phố Hồ Chí Minh','Thành phố Hồ Chí Minh',NULL,'VDV000305','2026-05-22 13:39:43',NULL),(10036,10036,'Nam 06','VĐV đội 03','NAM','2004-01-01','Thành phố Hồ Chí Minh','Thành phố Hồ Chí Minh',NULL,'VDV000306','2026-05-22 13:39:43',NULL),(10041,10041,'Nam 01','VĐV đội 04','NAM','2004-01-01','Thành phố Hà Nội','Thành phố Hà Nội',NULL,'VDV000401','2026-05-22 13:39:43',NULL),(10042,10042,'Nam 02','VĐV đội 04','NAM','2004-01-01','Thành phố Hà Nội','Thành phố Hà Nội',NULL,'VDV000402','2026-05-22 13:39:43',NULL),(10043,10043,'Nam 03','VĐV đội 04','NAM','2004-01-01','Thành phố Hà Nội','Thành phố Hà Nội',NULL,'VDV000403','2026-05-22 13:39:43',NULL),(10044,10044,'Nam 04','VĐV đội 04','NAM','2004-01-01','Thành phố Hà Nội','Thành phố Hà Nội',NULL,'VDV000404','2026-05-22 13:39:43',NULL),(10045,10045,'Nam 05','VĐV đội 04','NAM','2004-01-01','Thành phố Hà Nội','Thành phố Hà Nội',NULL,'VDV000405','2026-05-22 13:39:43',NULL),(10046,10046,'Nam 06','VĐV đội 04','NAM','2004-01-01','Thành phố Hà Nội','Thành phố Hà Nội',NULL,'VDV000406','2026-05-22 13:39:43',NULL),(10051,10051,'Nam 01','VĐV đội 05','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV000501','2026-05-22 13:39:43',NULL),(10052,10052,'Nam 02','VĐV đội 05','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV000502','2026-05-22 13:39:43',NULL),(10053,10053,'Nam 03','VĐV đội 05','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV000503','2026-05-22 13:39:43',NULL),(10054,10054,'Nam 04','VĐV đội 05','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV000504','2026-05-22 13:39:43',NULL),(10055,10055,'Nam 05','VĐV đội 05','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV000505','2026-05-22 13:39:43',NULL),(10056,10056,'Nam 06','VĐV đội 05','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV000506','2026-05-22 13:39:43',NULL),(10061,10061,'Nam 01','VĐV đội 06','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV000601','2026-05-22 13:39:43',NULL),(10062,10062,'Nam 02','VĐV đội 06','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV000602','2026-05-22 13:39:43',NULL),(10063,10063,'Nam 03','VĐV đội 06','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV000603','2026-05-22 13:39:43',NULL),(10064,10064,'Nam 04','VĐV đội 06','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV000604','2026-05-22 13:39:43',NULL),(10065,10065,'Nam 05','VĐV đội 06','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV000605','2026-05-22 13:39:43',NULL),(10066,10066,'Nam 06','VĐV đội 06','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV000606','2026-05-22 13:39:43',NULL),(10071,10071,'Nam 01','VĐV đội 07','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV000701','2026-05-22 13:39:43',NULL),(10072,10072,'Nam 02','VĐV đội 07','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV000702','2026-05-22 13:39:43',NULL),(10073,10073,'Nam 03','VĐV đội 07','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV000703','2026-05-22 13:39:43',NULL),(10074,10074,'Nam 04','VĐV đội 07','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV000704','2026-05-22 13:39:43',NULL),(10075,10075,'Nam 05','VĐV đội 07','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV000705','2026-05-22 13:39:43',NULL),(10076,10076,'Nam 06','VĐV đội 07','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV000706','2026-05-22 13:39:43',NULL),(10081,10081,'Nam 01','VĐV đội 08','NAM','2004-01-01','Thành phố Hồ Chí Minh','Thành phố Hồ Chí Minh',NULL,'VDV000801','2026-05-22 13:39:43',NULL),(10082,10082,'Nam 02','VĐV đội 08','NAM','2004-01-01','Thành phố Hồ Chí Minh','Thành phố Hồ Chí Minh',NULL,'VDV000802','2026-05-22 13:39:43',NULL),(10083,10083,'Nam 03','VĐV đội 08','NAM','2004-01-01','Thành phố Hồ Chí Minh','Thành phố Hồ Chí Minh',NULL,'VDV000803','2026-05-22 13:39:43',NULL),(10084,10084,'Nam 04','VĐV đội 08','NAM','2004-01-01','Thành phố Hồ Chí Minh','Thành phố Hồ Chí Minh',NULL,'VDV000804','2026-05-22 13:39:43',NULL),(10085,10085,'Nam 05','VĐV đội 08','NAM','2004-01-01','Thành phố Hồ Chí Minh','Thành phố Hồ Chí Minh',NULL,'VDV000805','2026-05-22 13:39:43',NULL),(10086,10086,'Nam 06','VĐV đội 08','NAM','2004-01-01','Thành phố Hồ Chí Minh','Thành phố Hồ Chí Minh',NULL,'VDV000806','2026-05-22 13:39:43',NULL),(10091,10091,'Nam 01','VĐV đội 09','NAM','2004-01-01','Thành phố Hồ Chí Minh','Thành phố Hồ Chí Minh',NULL,'VDV000901','2026-05-22 13:39:43',NULL),(10092,10092,'Nam 02','VĐV đội 09','NAM','2004-01-01','Thành phố Hồ Chí Minh','Thành phố Hồ Chí Minh',NULL,'VDV000902','2026-05-22 13:39:43',NULL),(10093,10093,'Nam 03','VĐV đội 09','NAM','2004-01-01','Thành phố Hồ Chí Minh','Thành phố Hồ Chí Minh',NULL,'VDV000903','2026-05-22 13:39:43',NULL),(10094,10094,'Nam 04','VĐV đội 09','NAM','2004-01-01','Thành phố Hồ Chí Minh','Thành phố Hồ Chí Minh',NULL,'VDV000904','2026-05-22 13:39:43',NULL),(10095,10095,'Nam 05','VĐV đội 09','NAM','2004-01-01','Thành phố Hồ Chí Minh','Thành phố Hồ Chí Minh',NULL,'VDV000905','2026-05-22 13:39:43',NULL),(10096,10096,'Nam 06','VĐV đội 09','NAM','2004-01-01','Thành phố Hồ Chí Minh','Thành phố Hồ Chí Minh',NULL,'VDV000906','2026-05-22 13:39:43',NULL),(10101,10101,'Nam 01','VĐV đội 10','NAM','2004-01-01','Thành phố Hồ Chí Minh','Thành phố Hồ Chí Minh',NULL,'VDV001001','2026-05-22 13:39:43',NULL),(10102,10102,'Nam 02','VĐV đội 10','NAM','2004-01-01','Thành phố Hồ Chí Minh','Thành phố Hồ Chí Minh',NULL,'VDV001002','2026-05-22 13:39:43',NULL),(10103,10103,'Nam 03','VĐV đội 10','NAM','2004-01-01','Thành phố Hồ Chí Minh','Thành phố Hồ Chí Minh',NULL,'VDV001003','2026-05-22 13:39:43',NULL),(10104,10104,'Nam 04','VĐV đội 10','NAM','2004-01-01','Thành phố Hồ Chí Minh','Thành phố Hồ Chí Minh',NULL,'VDV001004','2026-05-22 13:39:43',NULL),(10105,10105,'Nam 05','VĐV đội 10','NAM','2004-01-01','Thành phố Hồ Chí Minh','Thành phố Hồ Chí Minh',NULL,'VDV001005','2026-05-22 13:39:43',NULL),(10106,10106,'Nam 06','VĐV đội 10','NAM','2004-01-01','Thành phố Hồ Chí Minh','Thành phố Hồ Chí Minh',NULL,'VDV001006','2026-05-22 13:39:43',NULL),(10111,10111,'Nam 01','VĐV đội 11','NAM','2004-01-01','Thành phố Hà Nội','Thành phố Hà Nội',NULL,'VDV001101','2026-05-22 13:39:43',NULL),(10112,10112,'Nam 02','VĐV đội 11','NAM','2004-01-01','Thành phố Hà Nội','Thành phố Hà Nội',NULL,'VDV001102','2026-05-22 13:39:43',NULL),(10113,10113,'Nam 03','VĐV đội 11','NAM','2004-01-01','Thành phố Hà Nội','Thành phố Hà Nội',NULL,'VDV001103','2026-05-22 13:39:43',NULL),(10114,10114,'Nam 04','VĐV đội 11','NAM','2004-01-01','Thành phố Hà Nội','Thành phố Hà Nội',NULL,'VDV001104','2026-05-22 13:39:43',NULL),(10115,10115,'Nam 05','VĐV đội 11','NAM','2004-01-01','Thành phố Hà Nội','Thành phố Hà Nội',NULL,'VDV001105','2026-05-22 13:39:43',NULL),(10116,10116,'Nam 06','VĐV đội 11','NAM','2004-01-01','Thành phố Hà Nội','Thành phố Hà Nội',NULL,'VDV001106','2026-05-22 13:39:43',NULL),(10121,10121,'Nam 01','VĐV đội 12','NAM','2004-01-01','Thành phố Hà Nội','Thành phố Hà Nội',NULL,'VDV001201','2026-05-22 13:39:43',NULL),(10122,10122,'Nam 02','VĐV đội 12','NAM','2004-01-01','Thành phố Hà Nội','Thành phố Hà Nội',NULL,'VDV001202','2026-05-22 13:39:43',NULL),(10123,10123,'Nam 03','VĐV đội 12','NAM','2004-01-01','Thành phố Hà Nội','Thành phố Hà Nội',NULL,'VDV001203','2026-05-22 13:39:43',NULL),(10124,10124,'Nam 04','VĐV đội 12','NAM','2004-01-01','Thành phố Hà Nội','Thành phố Hà Nội',NULL,'VDV001204','2026-05-22 13:39:43',NULL),(10125,10125,'Nam 05','VĐV đội 12','NAM','2004-01-01','Thành phố Hà Nội','Thành phố Hà Nội',NULL,'VDV001205','2026-05-22 13:39:43',NULL),(10126,10126,'Nam 06','VĐV đội 12','NAM','2004-01-01','Thành phố Hà Nội','Thành phố Hà Nội',NULL,'VDV001206','2026-05-22 13:39:43',NULL),(10131,10131,'Nam 01','VĐV đội 13','NAM','2004-01-01','Thành phố Hà Nội','Thành phố Hà Nội',NULL,'VDV001301','2026-05-22 13:39:43',NULL),(10132,10132,'Nam 02','VĐV đội 13','NAM','2004-01-01','Thành phố Hà Nội','Thành phố Hà Nội',NULL,'VDV001302','2026-05-22 13:39:43',NULL),(10133,10133,'Nam 03','VĐV đội 13','NAM','2004-01-01','Thành phố Hà Nội','Thành phố Hà Nội',NULL,'VDV001303','2026-05-22 13:39:43',NULL),(10134,10134,'Nam 04','VĐV đội 13','NAM','2004-01-01','Thành phố Hà Nội','Thành phố Hà Nội',NULL,'VDV001304','2026-05-22 13:39:43',NULL),(10135,10135,'Nam 05','VĐV đội 13','NAM','2004-01-01','Thành phố Hà Nội','Thành phố Hà Nội',NULL,'VDV001305','2026-05-22 13:39:43',NULL),(10136,10136,'Nam 06','VĐV đội 13','NAM','2004-01-01','Thành phố Hà Nội','Thành phố Hà Nội',NULL,'VDV001306','2026-05-22 13:39:43',NULL),(10141,10141,'Nam 01','VĐV đội 14','NAM','2004-01-01','Phường Bến Thành, Thành phố Hồ Chí Minh','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'VDV001401','2026-05-22 13:39:43',NULL),(10142,10142,'Nam 02','VĐV đội 14','NAM','2004-01-01','Phường Bến Thành, Thành phố Hồ Chí Minh','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'VDV001402','2026-05-22 13:39:43',NULL),(10143,10143,'Nam 03','VĐV đội 14','NAM','2004-01-01','Phường Bến Thành, Thành phố Hồ Chí Minh','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'VDV001403','2026-05-22 13:39:43',NULL),(10144,10144,'Nam 04','VĐV đội 14','NAM','2004-01-01','Phường Bến Thành, Thành phố Hồ Chí Minh','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'VDV001404','2026-05-22 13:39:43',NULL),(10145,10145,'Nam 05','VĐV đội 14','NAM','2004-01-01','Phường Bến Thành, Thành phố Hồ Chí Minh','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'VDV001405','2026-05-22 13:39:43',NULL),(10146,10146,'Nam 06','VĐV đội 14','NAM','2004-01-01','Phường Bến Thành, Thành phố Hồ Chí Minh','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'VDV001406','2026-05-22 13:39:43',NULL),(10151,10151,'Nam 01','VĐV đội 15','NAM','2004-01-01','Phường Bến Thành, Thành phố Hồ Chí Minh','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'VDV001501','2026-05-22 13:39:43',NULL),(10152,10152,'Nam 02','VĐV đội 15','NAM','2004-01-01','Phường Bến Thành, Thành phố Hồ Chí Minh','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'VDV001502','2026-05-22 13:39:43',NULL),(10153,10153,'Nam 03','VĐV đội 15','NAM','2004-01-01','Phường Bến Thành, Thành phố Hồ Chí Minh','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'VDV001503','2026-05-22 13:39:43',NULL),(10154,10154,'Nam 04','VĐV đội 15','NAM','2004-01-01','Phường Bến Thành, Thành phố Hồ Chí Minh','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'VDV001504','2026-05-22 13:39:43',NULL),(10155,10155,'Nam 05','VĐV đội 15','NAM','2004-01-01','Phường Bến Thành, Thành phố Hồ Chí Minh','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'VDV001505','2026-05-22 13:39:43',NULL),(10156,10156,'Nam 06','VĐV đội 15','NAM','2004-01-01','Phường Bến Thành, Thành phố Hồ Chí Minh','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'VDV001506','2026-05-22 13:39:43',NULL),(10161,10161,'Nam 01','VĐV đội 16','NAM','2004-01-01','Phường Bến Thành, Thành phố Hồ Chí Minh','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'VDV001601','2026-05-22 13:39:43',NULL),(10162,10162,'Nam 02','VĐV đội 16','NAM','2004-01-01','Phường Bến Thành, Thành phố Hồ Chí Minh','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'VDV001602','2026-05-22 13:39:43',NULL),(10163,10163,'Nam 03','VĐV đội 16','NAM','2004-01-01','Phường Bến Thành, Thành phố Hồ Chí Minh','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'VDV001603','2026-05-22 13:39:43',NULL),(10164,10164,'Nam 04','VĐV đội 16','NAM','2004-01-01','Phường Bến Thành, Thành phố Hồ Chí Minh','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'VDV001604','2026-05-22 13:39:43',NULL),(10165,10165,'Nam 05','VĐV đội 16','NAM','2004-01-01','Phường Bến Thành, Thành phố Hồ Chí Minh','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'VDV001605','2026-05-22 13:39:43',NULL),(10166,10166,'Nam 06','VĐV đội 16','NAM','2004-01-01','Phường Bến Thành, Thành phố Hồ Chí Minh','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'VDV001606','2026-05-22 13:39:43',NULL),(10171,10171,'Nam 01','VĐV đội 17','NAM','2004-01-01','Phường Bến Thành, Thành phố Hồ Chí Minh','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'VDV001701','2026-05-22 13:39:43',NULL),(10172,10172,'Nam 02','VĐV đội 17','NAM','2004-01-01','Phường Bến Thành, Thành phố Hồ Chí Minh','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'VDV001702','2026-05-22 13:39:43',NULL),(10173,10173,'Nam 03','VĐV đội 17','NAM','2004-01-01','Phường Bến Thành, Thành phố Hồ Chí Minh','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'VDV001703','2026-05-22 13:39:43',NULL),(10174,10174,'Nam 04','VĐV đội 17','NAM','2004-01-01','Phường Bến Thành, Thành phố Hồ Chí Minh','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'VDV001704','2026-05-22 13:39:43',NULL),(10175,10175,'Nam 05','VĐV đội 17','NAM','2004-01-01','Phường Bến Thành, Thành phố Hồ Chí Minh','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'VDV001705','2026-05-22 13:39:43',NULL),(10176,10176,'Nam 06','VĐV đội 17','NAM','2004-01-01','Phường Bến Thành, Thành phố Hồ Chí Minh','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'VDV001706','2026-05-22 13:39:43',NULL),(10181,10181,'Nam 01','VĐV đội 18','NAM','2004-01-01','Phường Hoàn Kiếm, Thành phố Hà Nội','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'VDV001801','2026-05-22 13:39:43',NULL),(10182,10182,'Nam 02','VĐV đội 18','NAM','2004-01-01','Phường Hoàn Kiếm, Thành phố Hà Nội','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'VDV001802','2026-05-22 13:39:43',NULL),(10183,10183,'Nam 03','VĐV đội 18','NAM','2004-01-01','Phường Hoàn Kiếm, Thành phố Hà Nội','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'VDV001803','2026-05-22 13:39:43',NULL),(10184,10184,'Nam 04','VĐV đội 18','NAM','2004-01-01','Phường Hoàn Kiếm, Thành phố Hà Nội','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'VDV001804','2026-05-22 13:39:43',NULL),(10185,10185,'Nam 05','VĐV đội 18','NAM','2004-01-01','Phường Hoàn Kiếm, Thành phố Hà Nội','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'VDV001805','2026-05-22 13:39:43',NULL),(10186,10186,'Nam 06','VĐV đội 18','NAM','2004-01-01','Phường Hoàn Kiếm, Thành phố Hà Nội','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'VDV001806','2026-05-22 13:39:43',NULL),(10191,10191,'Nam 01','VĐV đội 19','NAM','2004-01-01','Phường Hoàn Kiếm, Thành phố Hà Nội','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'VDV001901','2026-05-22 13:39:43',NULL),(10192,10192,'Nam 02','VĐV đội 19','NAM','2004-01-01','Phường Hoàn Kiếm, Thành phố Hà Nội','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'VDV001902','2026-05-22 13:39:43',NULL),(10193,10193,'Nam 03','VĐV đội 19','NAM','2004-01-01','Phường Hoàn Kiếm, Thành phố Hà Nội','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'VDV001903','2026-05-22 13:39:43',NULL),(10194,10194,'Nam 04','VĐV đội 19','NAM','2004-01-01','Phường Hoàn Kiếm, Thành phố Hà Nội','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'VDV001904','2026-05-22 13:39:43',NULL),(10195,10195,'Nam 05','VĐV đội 19','NAM','2004-01-01','Phường Hoàn Kiếm, Thành phố Hà Nội','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'VDV001905','2026-05-22 13:39:43',NULL),(10196,10196,'Nam 06','VĐV đội 19','NAM','2004-01-01','Phường Hoàn Kiếm, Thành phố Hà Nội','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'VDV001906','2026-05-22 13:39:43',NULL),(10201,10201,'Nam 01','VĐV đội 20','NAM','2004-01-01','Phường Hoàn Kiếm, Thành phố Hà Nội','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'VDV002001','2026-05-22 13:39:43',NULL),(10202,10202,'Nam 02','VĐV đội 20','NAM','2004-01-01','Phường Hoàn Kiếm, Thành phố Hà Nội','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'VDV002002','2026-05-22 13:39:43',NULL),(10203,10203,'Nam 03','VĐV đội 20','NAM','2004-01-01','Phường Hoàn Kiếm, Thành phố Hà Nội','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'VDV002003','2026-05-22 13:39:43',NULL),(10204,10204,'Nam 04','VĐV đội 20','NAM','2004-01-01','Phường Hoàn Kiếm, Thành phố Hà Nội','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'VDV002004','2026-05-22 13:39:43',NULL),(10205,10205,'Nam 05','VĐV đội 20','NAM','2004-01-01','Phường Hoàn Kiếm, Thành phố Hà Nội','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'VDV002005','2026-05-22 13:39:43',NULL),(10206,10206,'Nam 06','VĐV đội 20','NAM','2004-01-01','Phường Hoàn Kiếm, Thành phố Hà Nội','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'VDV002006','2026-05-22 13:39:43',NULL),(10211,10211,'Nam 01','VĐV đội 21','NAM','2004-01-01','Phường Hoàn Kiếm, Thành phố Hà Nội','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'VDV002101','2026-05-22 13:39:43',NULL),(10212,10212,'Nam 02','VĐV đội 21','NAM','2004-01-01','Phường Hoàn Kiếm, Thành phố Hà Nội','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'VDV002102','2026-05-22 13:39:43',NULL),(10213,10213,'Nam 03','VĐV đội 21','NAM','2004-01-01','Phường Hoàn Kiếm, Thành phố Hà Nội','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'VDV002103','2026-05-22 13:39:43',NULL),(10214,10214,'Nam 04','VĐV đội 21','NAM','2004-01-01','Phường Hoàn Kiếm, Thành phố Hà Nội','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'VDV002104','2026-05-22 13:39:43',NULL),(10215,10215,'Nam 05','VĐV đội 21','NAM','2004-01-01','Phường Hoàn Kiếm, Thành phố Hà Nội','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'VDV002105','2026-05-22 13:39:43',NULL),(10216,10216,'Nam 06','VĐV đội 21','NAM','2004-01-01','Phường Hoàn Kiếm, Thành phố Hà Nội','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'VDV002106','2026-05-22 13:39:43',NULL),(10221,10221,'Nam 01','VĐV đội 22','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV002201','2026-05-22 13:50:53',NULL),(10222,10222,'Nam 02','VĐV đội 22','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV002202','2026-05-22 13:50:53',NULL),(10223,10223,'Nam 03','VĐV đội 22','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV002203','2026-05-22 13:50:53',NULL),(10224,10224,'Nam 04','VĐV đội 22','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV002204','2026-05-22 13:50:53',NULL),(10225,10225,'Nam 05','VĐV đội 22','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV002205','2026-05-22 13:50:53',NULL),(10226,10226,'Nam 06','VĐV đội 22','NAM','2004-01-01','Phường Sài Gòn, Thành phố Hồ Chí Minh','Phường Sài Gòn, Thành phố Hồ Chí Minh',NULL,'VDV002206','2026-05-22 13:50:53',NULL),(10231,10231,'Nam 01','VĐV đội 23','NAM','2004-01-01','Phường Bến Thành, Thành phố Hồ Chí Minh','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'VDV002301','2026-05-22 16:35:13',NULL),(10232,10232,'Nam 02','VĐV đội 23','NAM','2004-01-01','Phường Bến Thành, Thành phố Hồ Chí Minh','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'VDV002302','2026-05-22 16:35:13',NULL),(10233,10233,'Nam 03','VĐV đội 23','NAM','2004-01-01','Phường Bến Thành, Thành phố Hồ Chí Minh','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'VDV002303','2026-05-22 16:35:13',NULL),(10234,10234,'Nam 04','VĐV đội 23','NAM','2004-01-01','Phường Bến Thành, Thành phố Hồ Chí Minh','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'VDV002304','2026-05-22 16:35:13',NULL),(10235,10235,'Nam 05','VĐV đội 23','NAM','2004-01-01','Phường Bến Thành, Thành phố Hồ Chí Minh','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'VDV002305','2026-05-22 16:35:13',NULL),(10236,10236,'Nam 06','VĐV đội 23','NAM','2004-01-01','Phường Bến Thành, Thành phố Hồ Chí Minh','Phường Bến Thành, Thành phố Hồ Chí Minh',NULL,'VDV002306','2026-05-22 16:35:13',NULL),(10241,10241,'Nam 01','VĐV đội 24','NAM','2004-01-01','Phường Hoàn Kiếm, Thành phố Hà Nội','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'VDV002401','2026-05-22 16:35:13',NULL),(10242,10242,'Nam 02','VĐV đội 24','NAM','2004-01-01','Phường Hoàn Kiếm, Thành phố Hà Nội','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'VDV002402','2026-05-22 16:35:13',NULL),(10243,10243,'Nam 03','VĐV đội 24','NAM','2004-01-01','Phường Hoàn Kiếm, Thành phố Hà Nội','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'VDV002403','2026-05-22 16:35:13',NULL),(10244,10244,'Nam 04','VĐV đội 24','NAM','2004-01-01','Phường Hoàn Kiếm, Thành phố Hà Nội','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'VDV002404','2026-05-22 16:35:13',NULL),(10245,10245,'Nam 05','VĐV đội 24','NAM','2004-01-01','Phường Hoàn Kiếm, Thành phố Hà Nội','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'VDV002405','2026-05-22 16:35:13',NULL),(10246,10246,'Nam 06','VĐV đội 24','NAM','2004-01-01','Phường Hoàn Kiếm, Thành phố Hà Nội','Phường Hoàn Kiếm, Thành phố Hà Nội',NULL,'VDV002406','2026-05-22 16:35:13',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=528 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nhatkyhethong`
--

LOCK TABLES `nhatkyhethong` WRITE;
/*!40000 ALTER TABLE `nhatkyhethong` DISABLE KEYS */;
INSERT INTO `nhatkyhethong` VALUES (464,4,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-22 13:57:23','::1','Tai khoan #4 role BAN_TO_CHUC xem trang chu.'),(465,4,'Tao giai dau','Giaidau',108,'2026-05-22 14:47:55','::1','Ban to chuc #3 tao giai dau \"Phuong Sai Gon 2026\" theo cap #3, khu vuc #20.'),(466,4,'Cong bo giai dau','Giaidau',108,'2026-05-22 14:47:57','::1','Ban to chuc #3 cong bo giai dau \"Phuong Sai Gon 2026\".'),(467,4,'Mo dang ky giai dau','Giaidau',108,'2026-05-22 14:47:57','::1','Ban to chuc #3 mo dang ky giai dau \"Phuong Sai Gon 2026\". Trang thai: CHUA_MO -> DANG_MO.'),(468,5,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-22 14:48:41','::1','Tai khoan #5 role BAN_TO_CHUC xem trang chu.'),(469,20,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-22 14:54:50','::1','Tai khoan #20 role HUAN_LUYEN_VIEN xem trang chu.'),(470,20,'Dang ky giai dau','Dangkygiaidau',15,'2026-05-22 14:55:31','::1','HLV #5 dang ky doi #5 \"Đội TDTT Phường Sài Gòn 02\" tham gia giai dau #108 \"Phuong Sai Gon 2026\".'),(471,20,'Gui yeu cau xac nhan dang ky giai dau','Yeucauxacnhan',14,'2026-05-22 14:55:31','::1','HLV #5 dang ky doi #5 \"Đội TDTT Phường Sài Gòn 02\" tham gia giai dau #108 \"Phuong Sai Gon 2026\".'),(472,4,'Duyet dang ky doi bong','Dangkygiaidau',15,'2026-05-22 14:55:37','::1','Ban to chuc #3 duyet dang ky cua doi \"Đội TDTT Phường Sài Gòn 02\" vao giai dau \"Phuong Sai Gon 2026\".'),(473,21,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-22 16:01:39','::1','Tai khoan #21 role HUAN_LUYEN_VIEN xem trang chu.'),(474,4,'Tao giai dau','Giaidau',109,'2026-05-22 16:40:56','::1','Ban to chuc #3 tao giai dau \"P.SaiGon 2026-ver2\" theo cap #3, khu vuc #20.'),(475,4,'Cong bo giai dau','Giaidau',109,'2026-05-22 16:40:59','::1','Ban to chuc #3 cong bo giai dau \"P.SaiGon 2026-ver2\".'),(476,4,'Mo dang ky giai dau','Giaidau',109,'2026-05-22 16:40:59','::1','Ban to chuc #3 mo dang ky giai dau \"P.SaiGon 2026-ver2\". Trang thai: CHUA_MO -> DANG_MO.'),(477,6,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-22 16:41:51','::1','Tai khoan #6 role HUAN_LUYEN_VIEN xem trang chu.'),(478,6,'Dang ky giai dau','Dangkygiaidau',16,'2026-05-22 16:42:04','::1','HLV #1 dang ky doi #1 \"Đội Trung tâm TDTT Phường Sài Gòn\" tham gia giai dau #109 \"P.SaiGon 2026-ver2\".'),(479,6,'Gui yeu cau xac nhan dang ky giai dau','Yeucauxacnhan',15,'2026-05-22 16:42:04','::1','HLV #1 dang ky doi #1 \"Đội Trung tâm TDTT Phường Sài Gòn\" tham gia giai dau #109 \"P.SaiGon 2026-ver2\".'),(480,7,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-22 16:42:24','::1','Tai khoan #7 role HUAN_LUYEN_VIEN xem trang chu.'),(481,7,'Dang ky giai dau','Dangkygiaidau',17,'2026-05-22 16:42:32','::1','HLV #2 dang ky doi #2 \"Đội Tư nhân Phường Sài Gòn\" tham gia giai dau #109 \"P.SaiGon 2026-ver2\".'),(482,7,'Gui yeu cau xac nhan dang ky giai dau','Yeucauxacnhan',16,'2026-05-22 16:42:32','::1','HLV #2 dang ky doi #2 \"Đội Tư nhân Phường Sài Gòn\" tham gia giai dau #109 \"P.SaiGon 2026-ver2\".'),(483,4,'Duyet dang ky doi bong','Dangkygiaidau',17,'2026-05-22 16:43:36','::1','Ban to chuc #3 duyet dang ky cua doi \"Đội Tư nhân Phường Sài Gòn\" vao giai dau \"P.SaiGon 2026-ver2\".'),(484,4,'Duyet dang ky doi bong','Dangkygiaidau',16,'2026-05-22 16:43:36','::1','Ban to chuc #3 duyet dang ky cua doi \"Đội Trung tâm TDTT Phường Sài Gòn\" vao giai dau \"P.SaiGon 2026-ver2\".'),(485,4,'Dong dang ky giai dau','Giaidau',109,'2026-05-22 16:43:40','::1','Ban to chuc #3 dong dang ky giai dau \"P.SaiGon 2026-ver2\". Trang thai: DANG_MO -> DA_DONG.'),(486,7,'Xem lich thi dau doi bong','Trandau',NULL,'2026-05-22 16:43:55','::1','HLV #2 xem lich thi dau doi #2 \"Đội Tư nhân Phường Sài Gòn\". So tran: 0.'),(487,7,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-22 16:43:55','::1','Tai khoan #7 role HUAN_LUYEN_VIEN xem trang chu.'),(488,6,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-22 16:45:00','::1','Tai khoan #6 role HUAN_LUYEN_VIEN xem trang chu.'),(489,4,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-22 16:50:04','::1','Tai khoan #4 role BAN_TO_CHUC xem trang chu.'),(490,4,'Mo dang ky giai dau','Giaidau',109,'2026-05-22 16:50:34','::1','Ban to chuc #3 mo dang ky giai dau \"P.SaiGon 2026-ver2\". Trang thai: DA_DONG -> DANG_MO.'),(491,4,'Dong dang ky giai dau','Giaidau',109,'2026-05-22 16:50:43','::1','Ban to chuc #3 dong dang ky giai dau \"P.SaiGon 2026-ver2\". Trang thai: DANG_MO -> DA_DONG.'),(492,4,'Cap nhat giai dau','Giaidau',109,'2026-05-22 16:51:04','::1','Ban to chuc #3 cap nhat giai dau \"P.SaiGon 2026-ver2\". Truong thay doi: tengiaidau, mota, idcapgiaidau, idkhuvucphamvi, idluat, thoigianbatdau, thoigianketthuc, quymo, hinhanh, tinhchat, gioitinh, ghichu_diadiem, dieule, thethuc, quytac, dieukien.'),(493,4,'Cap nhat giai dau','Giaidau',109,'2026-05-22 16:51:43','::1','Ban to chuc #3 cap nhat giai dau \"P.SaiGon 2026-ver2\". Truong thay doi: tengiaidau, mota, idcapgiaidau, idkhuvucphamvi, idluat, thoigianbatdau, thoigianketthuc, quymo, hinhanh, tinhchat, gioitinh, ghichu_diadiem, dieule, thethuc, quytac, dieukien.'),(494,4,'Cap nhat giai dau','Giaidau',109,'2026-05-22 16:58:57','::1','Ban to chuc #3 cap nhat giai dau \"P.SaiGon 2026-ver2\". Truong thay doi: tengiaidau, mota, idcapgiaidau, idkhuvucphamvi, idluat, thoigianbatdau, thoigianketthuc, quymo, hinhanh, tinhchat, gioitinh, ghichu_diadiem, dieule, thethuc, quytac, dieukien.'),(495,4,'Them tran dau','Trandau',20,'2026-05-22 17:08:45','::1','Ban to chuc #3 them tran dau giai \"P.SaiGon 2026-ver2\": slot 1 doi #1, slot 2 doi #2, san #12, bat dau 2026-05-22 17:25:00.'),(496,4,'Cap nhat giai dau','Giaidau',109,'2026-05-22 17:09:03','::1','Ban to chuc #3 cap nhat giai dau \"P.SaiGon 2026-ver2\". Truong thay doi: tengiaidau, mota, idcapgiaidau, idkhuvucphamvi, idluat, thoigianbatdau, thoigianketthuc, quymo, hinhanh, tinhchat, gioitinh, ghichu_diadiem, dieule, thethuc, quytac, dieukien.'),(497,42,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-22 17:10:18','::1','Tai khoan #42 role TRONG_TAI xem trang chu.'),(498,42,'Xem danh sach giai dau duoc phan cong','Trongtai',12,'2026-05-22 17:10:21','::1','Trong tai #12 xem danh sach giai dau co phan cong. So dong: 1'),(499,42,'Xem danh sach san dau duoc phan cong','Trongtai',12,'2026-05-22 17:10:21','::1','Trong tai #12 xem danh sach san dau co phan cong. So dong: 1'),(500,42,'Xem lich phan cong trong tai','Trongtai',12,'2026-05-22 17:10:21','::1','Trong tai #12 xem lich phan cong tran dau. So dong: 1'),(501,42,'Xem giao dien giam sat tran dau','Trandau',20,'2026-05-22 17:10:25','::1','Trong tai #12 xem giao dien giam sat tran #20 (Đội Trung tâm TDTT Phường Sài Gòn vs Đội Tư nhân Phường Sài Gòn), giai #109.'),(502,42,'Xac nhan to trong tai tham gia','Trongtaitrandau',20,'2026-05-22 17:10:28','::1','Trong tai #12 xac nhan to trong tai tham gia tran #20. Danh sach: 12,10,11.'),(503,42,'Bat dau tran dau','Trandau',20,'2026-05-22 17:13:18','::1','Trong tai #12 Bat dau giam sat tran dau tran #20 (Đội Trung tâm TDTT Phường Sài Gòn vs Đội Tư nhân Phường Sài Gòn), giai #109.'),(504,42,'Tam dung tran dau','Trandau',20,'2026-05-22 17:14:10','::1','Trong tai #12 Tam dung tran dau tran #20 (Đội Trung tâm TDTT Phường Sài Gòn vs Đội Tư nhân Phường Sài Gòn), giai #109.'),(505,42,'Tiep tuc tran dau','Trandau',20,'2026-05-22 17:14:11','::1','Trong tai #12 Tiep tuc tran dau tran #20 (Đội Trung tâm TDTT Phường Sài Gòn vs Đội Tư nhân Phường Sài Gòn), giai #109.'),(506,42,'Tam dung tran dau','Trandau',20,'2026-05-22 17:14:13','::1','Trong tai #12 Tam dung tran dau tran #20 (Đội Trung tâm TDTT Phường Sài Gòn vs Đội Tư nhân Phường Sài Gòn), giai #109.'),(507,42,'Tiep tuc tran dau','Trandau',20,'2026-05-22 17:14:14','::1','Trong tai #12 Tiep tuc tran dau tran #20 (Đội Trung tâm TDTT Phường Sài Gòn vs Đội Tư nhân Phường Sài Gòn), giai #109.'),(508,42,'Tam dung tran dau','Trandau',20,'2026-05-22 17:14:15','::1','Trong tai #12 Tam dung tran dau tran #20 (Đội Trung tâm TDTT Phường Sài Gòn vs Đội Tư nhân Phường Sài Gòn), giai #109.'),(509,42,'Tiep tuc tran dau','Trandau',20,'2026-05-22 17:14:18','::1','Trong tai #12 Tiep tuc tran dau tran #20 (Đội Trung tâm TDTT Phường Sài Gòn vs Đội Tư nhân Phường Sài Gòn), giai #109.'),(510,42,'Tam dung tran dau','Trandau',20,'2026-05-22 17:14:23','::1','Trong tai #12 Tam dung tran dau tran #20 (Đội Trung tâm TDTT Phường Sài Gòn vs Đội Tư nhân Phường Sài Gòn), giai #109.'),(511,42,'Tiep tuc tran dau','Trandau',20,'2026-05-22 17:14:25','::1','Trong tai #12 Tiep tuc tran dau tran #20 (Đội Trung tâm TDTT Phường Sài Gòn vs Đội Tư nhân Phường Sài Gòn), giai #109.'),(512,42,'Ghi nhan ket qua tran dau','Ketquatrandau',13,'2026-05-22 17:14:30','::1','Trong tai #12 ghi nhan ket qua tran #20 (Đội Trung tâm TDTT Phường Sài Gòn vs Đội Tư nhân Phường Sài Gòn): diem 51-45, set 3-0, thang doi #1, chi tiet [1:17-15; 2:17-15; 3:17-15].'),(513,42,'Ket thuc tran dau','Trandau',20,'2026-05-22 17:14:30','::1','Trong tai #12 Ket thuc tran dau tran #20 (Đội Trung tâm TDTT Phường Sài Gòn vs Đội Tư nhân Phường Sài Gòn), giai #109.'),(514,42,'Xem danh sach giai dau duoc phan cong','Trongtai',12,'2026-05-22 17:14:34','::1','Trong tai #12 xem danh sach giai dau co phan cong. So dong: 1'),(515,42,'Xem danh sach san dau duoc phan cong','Trongtai',12,'2026-05-22 17:14:34','::1','Trong tai #12 xem danh sach san dau co phan cong. So dong: 1'),(516,42,'Xem lich phan cong trong tai','Trongtai',12,'2026-05-22 17:14:34','::1','Trong tai #12 xem lich phan cong tran dau. So dong: 1'),(517,42,'Xem thong tin chi tiet tran dau','Trandau',20,'2026-05-22 17:14:37','::1','Trong tai #12 xem thong tin chi tiet tran #20 (Đội Trung tâm TDTT Phường Sài Gòn vs Đội Tư nhân Phường Sài Gòn), giai #109.'),(518,42,'Xem thong tin chi tiet tran dau','Trandau',20,'2026-05-22 17:14:46','::1','Trong tai #12 xem thong tin chi tiet tran #20 (Đội Trung tâm TDTT Phường Sài Gòn vs Đội Tư nhân Phường Sài Gòn), giai #109.'),(519,42,'Xem danh sach giai dau duoc phan cong','Trongtai',12,'2026-05-22 17:31:22','::1','Trong tai #12 xem danh sach giai dau co phan cong. So dong: 1'),(520,42,'Xem danh sach san dau duoc phan cong','Trongtai',12,'2026-05-22 17:31:22','::1','Trong tai #12 xem danh sach san dau co phan cong. So dong: 1'),(521,42,'Xem lich phan cong trong tai','Trongtai',12,'2026-05-22 17:31:22','::1','Trong tai #12 xem lich phan cong tran dau. So dong: 1'),(522,42,'Xem thong tin chi tiet tran dau','Trandau',20,'2026-05-22 17:31:23','::1','Trong tai #12 xem thong tin chi tiet tran #20 (Đội Trung tâm TDTT Phường Sài Gòn vs Đội Tư nhân Phường Sài Gòn), giai #109.'),(523,42,'Xem danh sach don nghi phep trong tai','Trongtai',12,'2026-05-22 20:23:57','::1','Trong tai #12 xem danh sach don nghi phep. So dong: 0'),(524,42,'Xem danh sach tran dau co the bao cao su co','Trongtai',12,'2026-05-22 20:23:57','::1','Trong tai #12 xem danh sach tran dau co the bao cao su co. So dong: 1'),(525,42,'Xem danh sach bao cao su co','Trongtai',12,'2026-05-22 20:23:57','::1','Trong tai #12 xem danh sach bao cao su co. So dong: 0'),(526,4,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-22 20:24:42','::1','Tai khoan #4 role BAN_TO_CHUC xem trang chu.'),(527,3,'Xem trang chu dashboard','Dashboard',NULL,'2026-05-22 22:21:39','::1','Tai khoan #3 role BAN_TO_CHUC xem trang chu.');
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
) ENGINE=InnoDB AUTO_INCREMENT=143 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nhatkytrangthai`
--

LOCK TABLES `nhatkytrangthai` WRITE;
/*!40000 ALTER TABLE `nhatkytrangthai` DISABLE KEYS */;
INSERT INTO `nhatkytrangthai` VALUES (109,'GIAI_DAU',108,NULL,'NHAP','Tao giai dau o trang thai nhap',4,'2026-05-22 14:47:55'),(110,'GIAI_DAU',108,NULL,'DA_CONG_BO','Cong bo giai dau',4,'2026-05-22 14:47:57'),(111,'GIAI_DAU',108,'CHUA_MO','DANG_MO','Mo dang ky giai dau',4,'2026-05-22 14:47:57'),(112,'DANG_KY_GIAI',15,NULL,'CHO_DUYET','HLV dang ky giai dau',20,'2026-05-22 14:55:31'),(113,'YEU_CAU_XAC_NHAN',14,NULL,'CHO_DUYET','Gui yeu cau xac nhan dang ky giai dau',20,'2026-05-22 14:55:31'),(114,'DANG_KY_GIAI',15,'CHO_DUYET','DA_DUYET','Duyet dang ky doi bong',4,'2026-05-22 14:55:37'),(115,'YEU_CAU_XAC_NHAN',14,'CHO_DUYET','DA_DUYET','Duyet dang ky doi bong',4,'2026-05-22 14:55:37'),(116,'GIAI_DAU',108,'DA_CONG_BO','DANG_DIEN_RA','Tu dong chuyen sang dang dien ra theo ngay bat dau',NULL,'2026-05-22 15:41:54'),(117,'GIAI_DAU',109,NULL,'NHAP','Tao giai dau o trang thai nhap',4,'2026-05-22 16:40:56'),(118,'GIAI_DAU',109,NULL,'DA_CONG_BO','Cong bo giai dau',4,'2026-05-22 16:40:59'),(119,'GIAI_DAU',109,'CHUA_MO','DANG_MO','Mo dang ky giai dau',4,'2026-05-22 16:40:59'),(120,'DANG_KY_GIAI',16,NULL,'CHO_DUYET','HLV dang ky giai dau',6,'2026-05-22 16:42:04'),(121,'YEU_CAU_XAC_NHAN',15,NULL,'CHO_DUYET','Gui yeu cau xac nhan dang ky giai dau',6,'2026-05-22 16:42:04'),(122,'DANG_KY_GIAI',17,NULL,'CHO_DUYET','HLV dang ky giai dau',7,'2026-05-22 16:42:32'),(123,'YEU_CAU_XAC_NHAN',16,NULL,'CHO_DUYET','Gui yeu cau xac nhan dang ky giai dau',7,'2026-05-22 16:42:32'),(124,'DANG_KY_GIAI',17,'CHO_DUYET','DA_DUYET','Duyet dang ky doi bong',4,'2026-05-22 16:43:36'),(125,'YEU_CAU_XAC_NHAN',16,'CHO_DUYET','DA_DUYET','Duyet dang ky doi bong',4,'2026-05-22 16:43:36'),(126,'DANG_KY_GIAI',16,'CHO_DUYET','DA_DUYET','Duyet dang ky doi bong',4,'2026-05-22 16:43:36'),(127,'YEU_CAU_XAC_NHAN',15,'CHO_DUYET','DA_DUYET','Duyet dang ky doi bong',4,'2026-05-22 16:43:36'),(128,'GIAI_DAU',109,'DANG_MO','DA_DONG','Dong dang ky giai dau',4,'2026-05-22 16:43:40'),(129,'GIAI_DAU',109,'DA_DONG','DANG_MO','Mo dang ky giai dau',4,'2026-05-22 16:50:34'),(130,'GIAI_DAU',109,'DANG_MO','DA_DONG','Dong dang ky giai dau',4,'2026-05-22 16:50:43'),(131,'TRAN_DAU',20,NULL,'DA_XEP_LICH','Them tran dau',4,'2026-05-22 17:08:45'),(132,'TRAN_DAU',20,'DA_XEP_LICH','DANG_DIEN_RA','Bat dau tran dau',42,'2026-05-22 17:13:18'),(133,'TRAN_DAU',20,'DANG_DIEN_RA','TAM_DUNG','Tam dung tran dau',42,'2026-05-22 17:14:10'),(134,'TRAN_DAU',20,'TAM_DUNG','DANG_DIEN_RA','Tiep tuc tran dau',42,'2026-05-22 17:14:11'),(135,'TRAN_DAU',20,'DANG_DIEN_RA','TAM_DUNG','Tam dung tran dau',42,'2026-05-22 17:14:13'),(136,'TRAN_DAU',20,'TAM_DUNG','DANG_DIEN_RA','Tiep tuc tran dau',42,'2026-05-22 17:14:14'),(137,'TRAN_DAU',20,'DANG_DIEN_RA','TAM_DUNG','Tam dung tran dau',42,'2026-05-22 17:14:15'),(138,'TRAN_DAU',20,'TAM_DUNG','DANG_DIEN_RA','Tiep tuc tran dau',42,'2026-05-22 17:14:18'),(139,'TRAN_DAU',20,'DANG_DIEN_RA','TAM_DUNG','Tam dung tran dau',42,'2026-05-22 17:14:23'),(140,'TRAN_DAU',20,'TAM_DUNG','DANG_DIEN_RA','Tiep tuc tran dau',42,'2026-05-22 17:14:25'),(141,'TRAN_DAU',20,'DANG_DIEN_RA','DA_KET_THUC','Ket thuc tran dau',42,'2026-05-22 17:14:30'),(142,'GIAI_DAU',109,'DA_CONG_BO','DANG_DIEN_RA','Tu dong chuyen sang dang dien ra theo ngay bat dau',NULL,'2026-05-22 17:27:17');
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
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `phancongtrongtai`
--

LOCK TABLES `phancongtrongtai` WRITE;
/*!40000 ALTER TABLE `phancongtrongtai` DISABLE KEYS */;
INSERT INTO `phancongtrongtai` VALUES (15,20,10,'TRONG_TAI_CHINH','DA_XAC_NHAN','2026-05-22 17:08:45'),(16,20,11,'TRONG_TAI_PHU','DA_XAC_NHAN','2026-05-22 17:08:45'),(17,20,12,'GIAM_SAT','DA_XAC_NHAN','2026-05-22 17:08:45');
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
) ENGINE=InnoDB AUTO_INCREMENT=71 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `phiendangnhap`
--

LOCK TABLES `phiendangnhap` WRITE;
/*!40000 ALTER TABLE `phiendangnhap` DISABLE KEYS */;
INSERT INTO `phiendangnhap` VALUES (61,4,'cd42d66a8f9f3c282e3643e1f3938a97c46aef07e5d9faa2fcfc8727766ad8f1','2026-05-22 13:57:22','2026-05-22 16:44:37','DA_DANG_XUAT'),(62,5,'bb156e2ecf1f8b25d182566ce29e4cd246d20102728333366f08ed498978708e','2026-05-22 14:48:41','2026-05-22 14:54:45','DA_DANG_XUAT'),(63,20,'49f49eefcfc28b5ac06abf45e025d5b63bcebee03848e8678e2c70208057475e','2026-05-22 14:54:50','2026-05-22 16:01:13','DA_DANG_XUAT'),(64,21,'f97243df5f3f34e79fc1736cefa4324471cedd38d487a542d40137a9b89e5c64','2026-05-22 16:01:39','2026-05-22 16:41:04','DA_DANG_XUAT'),(65,6,'99cf3296505278bc8782919ebd1ea2c4b6a76b80e8f06a3fe4105e2451dac44d','2026-05-22 16:41:51','2026-05-22 16:42:07','DA_DANG_XUAT'),(66,7,'c6cae8521e6a3fe34757f3c39f78005afba890a33f7f02572b3b9bd2f42df565','2026-05-22 16:42:24','2026-05-22 16:44:57','DA_DANG_XUAT'),(67,6,'1f7645cd1e464ee62ff13ec68b36f8fb2a6c64a490be0f4513472f1aa8077538','2026-05-22 16:45:00','2026-05-22 17:10:11','DA_DANG_XUAT'),(68,4,'1e2be0c58045685df2b1f4ade85d71cc17a06760074167e55aa6f0fd73f838aa','2026-05-22 16:50:04',NULL,'DANG_HOAT_DONG'),(69,42,'0820ba00d338379841a59ee0bc8231c80a55c90a72bf72599f5214cf613e84a4','2026-05-22 17:10:18','2026-05-22 22:20:22','DA_DANG_XUAT'),(70,3,'41f533fb6e98d3f797ef6bcdffb489becf2b0eca7dff6dd291c5e4aaacfd7de1','2026-05-22 22:21:39',NULL,'DANG_HOAT_DONG');
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
INSERT INTO `quantrivien` VALUES (1,1,'SYS_ADMIN','Quản trị hệ thống dữ liệu mẫu.');
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
INSERT INTO `quyencapbtc_capgiaidau` VALUES (1,1,1,1,1,'BTC quốc gia quản lý giải quốc gia.'),(2,2,2,1,1,'BTC tỉnh/thành quản lý giải tỉnh/thành.'),(3,3,3,1,1,'BTC xã/phường quản lý giải xã/phường.');
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
  KEY `idx_qtcd_capdoi` (`capdoituongthamgia`),
  CONSTRAINT `fk_qtcd_capdoi_capchinhquyen` FOREIGN KEY (`capdoituongthamgia`) REFERENCES `capchinhquyen` (`macap`) ON UPDATE CASCADE,
  CONSTRAINT `fk_qtcd_capgiaidau_thanh_tich_nguon_v2` FOREIGN KEY (`idcapgiaidau_thanh_tich_nguon`) REFERENCES `capgiaidau` (`idcapgiaidau`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_qtcd_giaidau` FOREIGN KEY (`idgiaidau`) REFERENCES `giaidau` (`idgiaidau`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_qtcd_chedo` CHECK (`chedochondoi` in ('DANG_KY_THU_CONG','HE_THONG_GOI_Y','BTC_CHON_THU_CONG','KET_HOP')),
  CONSTRAINT `chk_qtcd_trangthai` CHECK (`trangthai` in ('HOAT_DONG','NGUNG_SU_DUNG'))
) ENGINE=InnoDB AUTO_INCREMENT=116 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quytacchondoi`
--

LOCK TABLES `quytacchondoi` WRITE;
/*!40000 ALTER TABLE `quytacchondoi` DISABLE KEYS */;
INSERT INTO `quytacchondoi` VALUES (101,101,'DANG_KY_THU_CONG','XA_PHUONG','KHONG_YEU_CAU',NULL,NULL,NULL,1,8,'Cấp xã/phường tự tổ chức để lọc đội tiềm năng.','HOAT_DONG'),(102,102,'KET_HOP','XA_PHUONG','VO_DICH',3,NULL,1,1,8,'Đội xã/phường cần có thành tích từ giải cấp xã/phường.','HOAT_DONG'),(103,103,'KET_HOP','TINH_THANH','VO_DICH',2,NULL,1,1,16,'Đội tỉnh/thành cần có thành tích từ giải cấp tỉnh/thành.','HOAT_DONG'),(110,108,'DANG_KY_THU_CONG','XA_PHUONG','KHONG_YEU_CAU',NULL,NULL,NULL,0,10,NULL,'HOAT_DONG'),(111,109,'DANG_KY_THU_CONG','XA_PHUONG','KHONG_YEU_CAU',NULL,NULL,NULL,0,10,NULL,'NGUNG_SU_DUNG'),(112,109,'DANG_KY_THU_CONG','XA_PHUONG','KHONG_YEU_CAU',NULL,NULL,NULL,0,10,NULL,'NGUNG_SU_DUNG'),(113,109,'DANG_KY_THU_CONG','XA_PHUONG','KHONG_YEU_CAU',NULL,NULL,NULL,0,10,NULL,'NGUNG_SU_DUNG'),(114,109,'DANG_KY_THU_CONG','XA_PHUONG','KHONG_YEU_CAU',NULL,NULL,NULL,0,10,NULL,'NGUNG_SU_DUNG'),(115,109,'DANG_KY_THU_CONG','XA_PHUONG','KHONG_YEU_CAU',NULL,NULL,NULL,0,10,NULL,'HOAT_DONG');
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
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sandau`
--

LOCK TABLES `sandau` WRITE;
/*!40000 ALTER TABLE `sandau` DISABLE KEYS */;
INSERT INTO `sandau` VALUES (12,6,'Sân 1 - Cụm sân Trung tâm TDTT Phường Sài Gòn','SAN_CHINH','Sàn thể thao đa năng','18m x 9m',300,'Sân chính dữ liệu mẫu của Cụm sân Trung tâm TDTT Phường Sài Gòn.','HOAT_DONG','2026-05-22 17:07:47',NULL),(13,6,'Sân 2 - Cụm sân Trung tâm TDTT Phường Sài Gòn','SAN_PHU','Sàn thể thao đa năng','18m x 9m',300,'Sân phụ dữ liệu mẫu của Cụm sân Trung tâm TDTT Phường Sài Gòn.','HOAT_DONG','2026-05-22 17:07:47',NULL),(14,6,'Sân 3 - Cụm sân Trung tâm TDTT Phường Sài Gòn','SAN_PHU','Sàn thể thao đa năng','18m x 9m',300,'Sân phụ dữ liệu mẫu của Cụm sân Trung tâm TDTT Phường Sài Gòn.','HOAT_DONG','2026-05-22 17:07:47',NULL),(15,6,'Sân 4 - Cụm sân Trung tâm TDTT Phường Sài Gòn','SAN_PHU','Sàn thể thao đa năng','18m x 9m',300,'Sân phụ dữ liệu mẫu của Cụm sân Trung tâm TDTT Phường Sài Gòn.','HOAT_DONG','2026-05-22 17:07:47',NULL),(16,7,'Sân 1 - Cụm sân Trung tâm TDTT Phường Bến Thành','SAN_CHINH','Sàn thể thao đa năng','18m x 9m',300,'Sân chính dữ liệu mẫu của Cụm sân Trung tâm TDTT Phường Bến Thành.','HOAT_DONG','2026-05-22 17:07:47',NULL),(17,7,'Sân 2 - Cụm sân Trung tâm TDTT Phường Bến Thành','SAN_PHU','Sàn thể thao đa năng','18m x 9m',300,'Sân phụ dữ liệu mẫu của Cụm sân Trung tâm TDTT Phường Bến Thành.','HOAT_DONG','2026-05-22 17:07:47',NULL),(18,7,'Sân 3 - Cụm sân Trung tâm TDTT Phường Bến Thành','SAN_PHU','Sàn thể thao đa năng','18m x 9m',300,'Sân phụ dữ liệu mẫu của Cụm sân Trung tâm TDTT Phường Bến Thành.','HOAT_DONG','2026-05-22 17:07:47',NULL),(19,7,'Sân 4 - Cụm sân Trung tâm TDTT Phường Bến Thành','SAN_PHU','Sàn thể thao đa năng','18m x 9m',300,'Sân phụ dữ liệu mẫu của Cụm sân Trung tâm TDTT Phường Bến Thành.','HOAT_DONG','2026-05-22 17:07:47',NULL),(20,8,'Sân 1 - Cụm sân Trung tâm TDTT Phường Hoàn Kiếm','SAN_CHINH','Sàn thể thao đa năng','18m x 9m',300,'Sân chính dữ liệu mẫu của Cụm sân Trung tâm TDTT Phường Hoàn Kiếm.','HOAT_DONG','2026-05-22 17:07:47',NULL),(21,8,'Sân 2 - Cụm sân Trung tâm TDTT Phường Hoàn Kiếm','SAN_PHU','Sàn thể thao đa năng','18m x 9m',300,'Sân phụ dữ liệu mẫu của Cụm sân Trung tâm TDTT Phường Hoàn Kiếm.','HOAT_DONG','2026-05-22 17:07:47',NULL),(22,8,'Sân 3 - Cụm sân Trung tâm TDTT Phường Hoàn Kiếm','SAN_PHU','Sàn thể thao đa năng','18m x 9m',300,'Sân phụ dữ liệu mẫu của Cụm sân Trung tâm TDTT Phường Hoàn Kiếm.','HOAT_DONG','2026-05-22 17:07:47',NULL),(23,8,'Sân 4 - Cụm sân Trung tâm TDTT Phường Hoàn Kiếm','SAN_PHU','Sàn thể thao đa năng','18m x 9m',300,'Sân phụ dữ liệu mẫu của Cụm sân Trung tâm TDTT Phường Hoàn Kiếm.','HOAT_DONG','2026-05-22 17:07:47',NULL),(24,9,'Sân 1 - Cụm sân Trung tâm HL và thi đấu TDTT Thành phố Hồ Chí Minh','SAN_CHINH','Sàn thể thao đa năng','18m x 9m',1200,'Sân chính dữ liệu mẫu của Cụm sân Trung tâm HL và thi đấu TDTT Thành phố Hồ Chí Minh.','HOAT_DONG','2026-05-22 17:07:47',NULL),(25,9,'Sân 2 - Cụm sân Trung tâm HL và thi đấu TDTT Thành phố Hồ Chí Minh','SAN_PHU','Sàn thể thao đa năng','18m x 9m',1200,'Sân phụ dữ liệu mẫu của Cụm sân Trung tâm HL và thi đấu TDTT Thành phố Hồ Chí Minh.','HOAT_DONG','2026-05-22 17:07:47',NULL),(26,9,'Sân 3 - Cụm sân Trung tâm HL và thi đấu TDTT Thành phố Hồ Chí Minh','SAN_PHU','Sàn thể thao đa năng','18m x 9m',1200,'Sân phụ dữ liệu mẫu của Cụm sân Trung tâm HL và thi đấu TDTT Thành phố Hồ Chí Minh.','HOAT_DONG','2026-05-22 17:07:47',NULL),(27,9,'Sân 4 - Cụm sân Trung tâm HL và thi đấu TDTT Thành phố Hồ Chí Minh','SAN_PHU','Sàn thể thao đa năng','18m x 9m',1200,'Sân phụ dữ liệu mẫu của Cụm sân Trung tâm HL và thi đấu TDTT Thành phố Hồ Chí Minh.','HOAT_DONG','2026-05-22 17:07:47',NULL),(28,9,'Sân 5 - Cụm sân Trung tâm HL và thi đấu TDTT Thành phố Hồ Chí Minh','SAN_PHU','Sàn thể thao đa năng','18m x 9m',1200,'Sân phụ dữ liệu mẫu của Cụm sân Trung tâm HL và thi đấu TDTT Thành phố Hồ Chí Minh.','HOAT_DONG','2026-05-22 17:07:47',NULL),(29,9,'Sân 6 - Cụm sân Trung tâm HL và thi đấu TDTT Thành phố Hồ Chí Minh','SAN_PHU','Sàn thể thao đa năng','18m x 9m',1200,'Sân phụ dữ liệu mẫu của Cụm sân Trung tâm HL và thi đấu TDTT Thành phố Hồ Chí Minh.','HOAT_DONG','2026-05-22 17:07:47',NULL),(30,10,'Sân 1 - Cụm sân Trung tâm HL và thi đấu TDTT Thành phố Hà Nội','SAN_CHINH','Sàn thể thao đa năng','18m x 9m',1200,'Sân chính dữ liệu mẫu của Cụm sân Trung tâm HL và thi đấu TDTT Thành phố Hà Nội.','HOAT_DONG','2026-05-22 17:07:47',NULL),(31,10,'Sân 2 - Cụm sân Trung tâm HL và thi đấu TDTT Thành phố Hà Nội','SAN_PHU','Sàn thể thao đa năng','18m x 9m',1200,'Sân phụ dữ liệu mẫu của Cụm sân Trung tâm HL và thi đấu TDTT Thành phố Hà Nội.','HOAT_DONG','2026-05-22 17:07:47',NULL),(32,10,'Sân 3 - Cụm sân Trung tâm HL và thi đấu TDTT Thành phố Hà Nội','SAN_PHU','Sàn thể thao đa năng','18m x 9m',1200,'Sân phụ dữ liệu mẫu của Cụm sân Trung tâm HL và thi đấu TDTT Thành phố Hà Nội.','HOAT_DONG','2026-05-22 17:07:47',NULL),(33,10,'Sân 4 - Cụm sân Trung tâm HL và thi đấu TDTT Thành phố Hà Nội','SAN_PHU','Sàn thể thao đa năng','18m x 9m',1200,'Sân phụ dữ liệu mẫu của Cụm sân Trung tâm HL và thi đấu TDTT Thành phố Hà Nội.','HOAT_DONG','2026-05-22 17:07:47',NULL),(34,10,'Sân 5 - Cụm sân Trung tâm HL và thi đấu TDTT Thành phố Hà Nội','SAN_PHU','Sàn thể thao đa năng','18m x 9m',1200,'Sân phụ dữ liệu mẫu của Cụm sân Trung tâm HL và thi đấu TDTT Thành phố Hà Nội.','HOAT_DONG','2026-05-22 17:07:47',NULL),(35,10,'Sân 6 - Cụm sân Trung tâm HL và thi đấu TDTT Thành phố Hà Nội','SAN_PHU','Sàn thể thao đa năng','18m x 9m',1200,'Sân phụ dữ liệu mẫu của Cụm sân Trung tâm HL và thi đấu TDTT Thành phố Hà Nội.','HOAT_DONG','2026-05-22 17:07:47',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=10247 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `taikhoan`
--

LOCK TABLES `taikhoan` WRITE;
/*!40000 ALTER TABLE `taikhoan` DISABLE KEYS */;
INSERT INTO `taikhoan` VALUES (1,'admin','$2y$10$2MxeQIee/Vf7B6R3DDbkge3lKjLm2sNjVLmW5HD28dUIgDSrAMjFm','admin@vtms.vn','0900000001',1,'HOAT_DONG','2026-05-22 10:47:00',NULL),(2,'btc_quocgia','$2y$10$OBXJKXgj9/3ht4mUK4rQb.SuXMd6rbqObYTDGMGpVzuYSgNT5DSY.','btc.quocgia@vtms.vn','0900000002',2,'HOAT_DONG','2026-05-22 10:47:00',NULL),(3,'btc_hcm','$2y$10$m5vRzWBL/Qg29A4Fysndh.yck4Z4H4ia9AWwRG5D58xzeJYayahKG','btc.hcm@vtms.vn','0900000003',2,'HOAT_DONG','2026-05-22 10:47:00',NULL),(4,'btc_phuong_saigon','$2y$10$zwD2YFXE.BNHCe7wbRQB4e269EqgN/s7gcpYJmzrvAjbb0CmDhzP.','btc.phuong.saigon@vtms.vn','0900000004',2,'HOAT_DONG','2026-05-22 10:47:00',NULL),(5,'btc_tt_tdtt_saigon','$2y$10$LbcnGxDL1zlKUuq1yPsdw.ihAx9OEywBMxvcMQtJGlwFV8R6GYuG6','btc.tttdtt.saigon@vtms.vn','0900000005',2,'HOAT_DONG','2026-05-22 10:47:00',NULL),(6,'hlv_tt_tdtt_saigon','$2y$10$.Ca7DM1fbv0rwVoFMrMIteK1NnwD58sWAm7/KPz23riYeFTRaAzri','hlv.tttdtt.saigon@vtms.vn','0900000006',4,'HOAT_DONG','2026-05-22 10:47:00',NULL),(7,'hlv_tunhan_saigon','$2y$10$kl/CO.sa7Lf6P79/CKO2HOHNTArTa6mvehMISb.CpkjcPpckv0ila','hlv.tunhan.saigon@vtms.vn','0900000007',4,'HOAT_DONG','2026-05-22 10:47:00',NULL),(8,'hlv_tphcm','$2y$10$qkM5X4gdud7IwcGU9iHZLOotYXnNqu2EEAXHN28X/lVe/114SM62e','hlv.tphcm@vtms.vn','0900000008',4,'HOAT_DONG','2026-05-22 10:47:00',NULL),(9,'hlv_hanoi','$2y$10$CftvRaET2BctRI/mvucoF.GXZM5r.dbRftZEFY1ykU.NtUyLx.JWi','hlv.hanoi@vtms.vn','0900000009',4,'HOAT_DONG','2026-05-22 10:47:00',NULL),(10,'btc_tdtt_tphcm','$2y$10$OBXJKXgj9/3ht4mUK4rQb.SuXMd6rbqObYTDGMGpVzuYSgNT5DSY.','btc.tdtt.tphcm@vtms.vn','0900000010',2,'HOAT_DONG','2026-05-22 13:39:43',NULL),(11,'btc_tdtt_hanoi','$2y$10$OBXJKXgj9/3ht4mUK4rQb.SuXMd6rbqObYTDGMGpVzuYSgNT5DSY.','btc.tdtt.hanoi@vtms.vn','0900000011',2,'HOAT_DONG','2026-05-22 13:39:43',NULL),(12,'btc_tdtt_benthanh','$2y$10$OBXJKXgj9/3ht4mUK4rQb.SuXMd6rbqObYTDGMGpVzuYSgNT5DSY.','btc.tdtt.benthanh@vtms.vn','0900000012',2,'HOAT_DONG','2026-05-22 13:39:43',NULL),(13,'btc_tdtt_hoankiem','$2y$10$OBXJKXgj9/3ht4mUK4rQb.SuXMd6rbqObYTDGMGpVzuYSgNT5DSY.','btc.tdtt.hoankiem@vtms.vn','0900000013',2,'HOAT_DONG','2026-05-22 13:39:43',NULL),(14,'btc_hanoi','$2y$10$OBXJKXgj9/3ht4mUK4rQb.SuXMd6rbqObYTDGMGpVzuYSgNT5DSY.','btc.hanoi@vtms.vn','0900000014',2,'HOAT_DONG','2026-05-22 13:39:43',NULL),(15,'btc_ben_thanh','$2y$10$OBXJKXgj9/3ht4mUK4rQb.SuXMd6rbqObYTDGMGpVzuYSgNT5DSY.','btc.benthanh@vtms.vn','0900000015',2,'HOAT_DONG','2026-05-22 13:39:43',NULL),(16,'btc_hoan_kiem','$2y$10$OBXJKXgj9/3ht4mUK4rQb.SuXMd6rbqObYTDGMGpVzuYSgNT5DSY.','btc.hoankiem@vtms.vn','0900000016',2,'HOAT_DONG','2026-05-22 13:39:43',NULL),(17,'btc_tu_nhan_saigon','$2y$10$OBXJKXgj9/3ht4mUK4rQb.SuXMd6rbqObYTDGMGpVzuYSgNT5DSY.','btc.tunhan.saigon@vtms.vn','0900000017',2,'HOAT_DONG','2026-05-22 13:50:53',NULL),(20,'hlv_tdtt_sg_02','$2y$10$.Ca7DM1fbv0rwVoFMrMIteK1NnwD58sWAm7/KPz23riYeFTRaAzri','hlv.tdtt.sg02@vtms.vn','0900000020',4,'HOAT_DONG','2026-05-22 13:39:43',NULL),(21,'hlv_tdtt_sg_03','$2y$10$.Ca7DM1fbv0rwVoFMrMIteK1NnwD58sWAm7/KPz23riYeFTRaAzri','hlv.tdtt.sg03@vtms.vn','0900000021',4,'HOAT_DONG','2026-05-22 13:39:43',NULL),(22,'hlv_tdtt_sg_04','$2y$10$.Ca7DM1fbv0rwVoFMrMIteK1NnwD58sWAm7/KPz23riYeFTRaAzri','hlv.tdtt.sg04@vtms.vn','0900000022',4,'HOAT_DONG','2026-05-22 13:39:43',NULL),(23,'hlv_tdtt_tphcm_02','$2y$10$.Ca7DM1fbv0rwVoFMrMIteK1NnwD58sWAm7/KPz23riYeFTRaAzri','hlv.tdtt.tphcm02@vtms.vn','0900000023',4,'HOAT_DONG','2026-05-22 13:39:43',NULL),(24,'hlv_tdtt_tphcm_03','$2y$10$.Ca7DM1fbv0rwVoFMrMIteK1NnwD58sWAm7/KPz23riYeFTRaAzri','hlv.tdtt.tphcm03@vtms.vn','0900000024',4,'HOAT_DONG','2026-05-22 13:39:43',NULL),(25,'hlv_tdtt_tphcm_04','$2y$10$.Ca7DM1fbv0rwVoFMrMIteK1NnwD58sWAm7/KPz23riYeFTRaAzri','hlv.tdtt.tphcm04@vtms.vn','0900000025',4,'HOAT_DONG','2026-05-22 13:39:43',NULL),(26,'hlv_tdtt_hanoi_02','$2y$10$.Ca7DM1fbv0rwVoFMrMIteK1NnwD58sWAm7/KPz23riYeFTRaAzri','hlv.tdtt.hanoi02@vtms.vn','0900000026',4,'HOAT_DONG','2026-05-22 13:39:43',NULL),(27,'hlv_tdtt_hanoi_03','$2y$10$.Ca7DM1fbv0rwVoFMrMIteK1NnwD58sWAm7/KPz23riYeFTRaAzri','hlv.tdtt.hanoi03@vtms.vn','0900000027',4,'HOAT_DONG','2026-05-22 13:39:43',NULL),(28,'hlv_tdtt_hanoi_04','$2y$10$.Ca7DM1fbv0rwVoFMrMIteK1NnwD58sWAm7/KPz23riYeFTRaAzri','hlv.tdtt.hanoi04@vtms.vn','0900000028',4,'HOAT_DONG','2026-05-22 13:39:43',NULL),(29,'hlv_tdtt_benthanh_01','$2y$10$.Ca7DM1fbv0rwVoFMrMIteK1NnwD58sWAm7/KPz23riYeFTRaAzri','hlv.tdtt.benthanh01@vtms.vn','0900000029',4,'HOAT_DONG','2026-05-22 13:39:43',NULL),(30,'hlv_tdtt_benthanh_02','$2y$10$.Ca7DM1fbv0rwVoFMrMIteK1NnwD58sWAm7/KPz23riYeFTRaAzri','hlv.tdtt.benthanh02@vtms.vn','0900000030',4,'HOAT_DONG','2026-05-22 13:39:43',NULL),(31,'hlv_tdtt_benthanh_03','$2y$10$.Ca7DM1fbv0rwVoFMrMIteK1NnwD58sWAm7/KPz23riYeFTRaAzri','hlv.tdtt.benthanh03@vtms.vn','0900000031',4,'HOAT_DONG','2026-05-22 13:39:43',NULL),(32,'hlv_tdtt_benthanh_04','$2y$10$.Ca7DM1fbv0rwVoFMrMIteK1NnwD58sWAm7/KPz23riYeFTRaAzri','hlv.tdtt.benthanh04@vtms.vn','0900000032',4,'HOAT_DONG','2026-05-22 13:39:43',NULL),(33,'hlv_tdtt_hoankiem_01','$2y$10$.Ca7DM1fbv0rwVoFMrMIteK1NnwD58sWAm7/KPz23riYeFTRaAzri','hlv.tdtt.hoankiem01@vtms.vn','0900000033',4,'HOAT_DONG','2026-05-22 13:39:43',NULL),(34,'hlv_tdtt_hoankiem_02','$2y$10$.Ca7DM1fbv0rwVoFMrMIteK1NnwD58sWAm7/KPz23riYeFTRaAzri','hlv.tdtt.hoankiem02@vtms.vn','0900000034',4,'HOAT_DONG','2026-05-22 13:39:43',NULL),(35,'hlv_tdtt_hoankiem_03','$2y$10$.Ca7DM1fbv0rwVoFMrMIteK1NnwD58sWAm7/KPz23riYeFTRaAzri','hlv.tdtt.hoankiem03@vtms.vn','0900000035',4,'HOAT_DONG','2026-05-22 13:39:43',NULL),(36,'hlv_tdtt_hoankiem_04','$2y$10$.Ca7DM1fbv0rwVoFMrMIteK1NnwD58sWAm7/KPz23riYeFTRaAzri','hlv.tdtt.hoankiem04@vtms.vn','0900000036',4,'HOAT_DONG','2026-05-22 13:39:43',NULL),(37,'hlv_tu_nhan_ngoai_saigon','$2y$10$.Ca7DM1fbv0rwVoFMrMIteK1NnwD58sWAm7/KPz23riYeFTRaAzri','hlv.tunhan.ngoai.saigon@vtms.vn','0900000037',4,'HOAT_DONG','2026-05-22 13:50:53',NULL),(38,'hlv_tu_nhan_benthanh','$2y$10$.Ca7DM1fbv0rwVoFMrMIteK1NnwD58sWAm7/KPz23riYeFTRaAzri','hlv.tunhan.benthanh@vtms.vn','0900000038',4,'HOAT_DONG','2026-05-22 16:35:13',NULL),(39,'hlv_tu_nhan_hoankiem','$2y$10$.Ca7DM1fbv0rwVoFMrMIteK1NnwD58sWAm7/KPz23riYeFTRaAzri','hlv.tunhan.hoankiem@vtms.vn','0900000039',4,'HOAT_DONG','2026-05-22 16:35:13',NULL),(40,'ref_phuong_saigon_01','$2y$10$/mb1U9yUqgxW3MUVp51/PObdmHJIi252.RRsvKeGhzqq2xpeTbGyu','ref.phuong.saigon01@vtms.vn','0900000040',3,'HOAT_DONG','2026-05-22 16:58:22',NULL),(41,'ref_phuong_saigon_02','$2y$10$/mb1U9yUqgxW3MUVp51/PObdmHJIi252.RRsvKeGhzqq2xpeTbGyu','ref.phuong.saigon02@vtms.vn','0900000041',3,'HOAT_DONG','2026-05-22 16:58:22',NULL),(42,'ref_phuong_saigon_03','$2y$10$/mb1U9yUqgxW3MUVp51/PObdmHJIi252.RRsvKeGhzqq2xpeTbGyu','ref.phuong.saigon03@vtms.vn','0900000042',3,'HOAT_DONG','2026-05-22 16:58:22',NULL),(43,'ref_phuong_benthanh_01','$2y$10$/mb1U9yUqgxW3MUVp51/PObdmHJIi252.RRsvKeGhzqq2xpeTbGyu','ref.phuong.benthanh01@vtms.vn','0900000043',3,'HOAT_DONG','2026-05-22 16:58:22',NULL),(44,'ref_phuong_benthanh_02','$2y$10$/mb1U9yUqgxW3MUVp51/PObdmHJIi252.RRsvKeGhzqq2xpeTbGyu','ref.phuong.benthanh02@vtms.vn','0900000044',3,'HOAT_DONG','2026-05-22 16:58:22',NULL),(45,'ref_phuong_benthanh_03','$2y$10$/mb1U9yUqgxW3MUVp51/PObdmHJIi252.RRsvKeGhzqq2xpeTbGyu','ref.phuong.benthanh03@vtms.vn','0900000045',3,'HOAT_DONG','2026-05-22 16:58:22',NULL),(46,'ref_phuong_hoankiem_01','$2y$10$/mb1U9yUqgxW3MUVp51/PObdmHJIi252.RRsvKeGhzqq2xpeTbGyu','ref.phuong.hoankiem01@vtms.vn','0900000046',3,'HOAT_DONG','2026-05-22 16:58:22',NULL),(47,'ref_phuong_hoankiem_02','$2y$10$/mb1U9yUqgxW3MUVp51/PObdmHJIi252.RRsvKeGhzqq2xpeTbGyu','ref.phuong.hoankiem02@vtms.vn','0900000047',3,'HOAT_DONG','2026-05-22 16:58:22',NULL),(48,'ref_phuong_hoankiem_03','$2y$10$/mb1U9yUqgxW3MUVp51/PObdmHJIi252.RRsvKeGhzqq2xpeTbGyu','ref.phuong.hoankiem03@vtms.vn','0900000048',3,'HOAT_DONG','2026-05-22 16:58:22',NULL),(10011,'vdv_d01_1','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d01.1@vtms.vn','093001001',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10012,'vdv_d01_2','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d01.2@vtms.vn','093001002',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10013,'vdv_d01_3','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d01.3@vtms.vn','093001003',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10014,'vdv_d01_4','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d01.4@vtms.vn','093001004',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10015,'vdv_d01_5','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d01.5@vtms.vn','093001005',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10016,'vdv_d01_6','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d01.6@vtms.vn','093001006',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10021,'vdv_d02_1','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d02.1@vtms.vn','093002001',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10022,'vdv_d02_2','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d02.2@vtms.vn','093002002',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10023,'vdv_d02_3','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d02.3@vtms.vn','093002003',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10024,'vdv_d02_4','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d02.4@vtms.vn','093002004',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10025,'vdv_d02_5','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d02.5@vtms.vn','093002005',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10026,'vdv_d02_6','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d02.6@vtms.vn','093002006',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10031,'vdv_d03_1','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d03.1@vtms.vn','093003001',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10032,'vdv_d03_2','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d03.2@vtms.vn','093003002',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10033,'vdv_d03_3','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d03.3@vtms.vn','093003003',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10034,'vdv_d03_4','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d03.4@vtms.vn','093003004',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10035,'vdv_d03_5','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d03.5@vtms.vn','093003005',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10036,'vdv_d03_6','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d03.6@vtms.vn','093003006',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10041,'vdv_d04_1','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d04.1@vtms.vn','093004001',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10042,'vdv_d04_2','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d04.2@vtms.vn','093004002',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10043,'vdv_d04_3','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d04.3@vtms.vn','093004003',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10044,'vdv_d04_4','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d04.4@vtms.vn','093004004',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10045,'vdv_d04_5','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d04.5@vtms.vn','093004005',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10046,'vdv_d04_6','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d04.6@vtms.vn','093004006',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10051,'vdv_d05_1','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d05.1@vtms.vn','093005001',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10052,'vdv_d05_2','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d05.2@vtms.vn','093005002',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10053,'vdv_d05_3','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d05.3@vtms.vn','093005003',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10054,'vdv_d05_4','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d05.4@vtms.vn','093005004',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10055,'vdv_d05_5','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d05.5@vtms.vn','093005005',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10056,'vdv_d05_6','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d05.6@vtms.vn','093005006',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10061,'vdv_d06_1','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d06.1@vtms.vn','093006001',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10062,'vdv_d06_2','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d06.2@vtms.vn','093006002',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10063,'vdv_d06_3','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d06.3@vtms.vn','093006003',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10064,'vdv_d06_4','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d06.4@vtms.vn','093006004',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10065,'vdv_d06_5','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d06.5@vtms.vn','093006005',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10066,'vdv_d06_6','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d06.6@vtms.vn','093006006',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10071,'vdv_d07_1','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d07.1@vtms.vn','093007001',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10072,'vdv_d07_2','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d07.2@vtms.vn','093007002',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10073,'vdv_d07_3','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d07.3@vtms.vn','093007003',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10074,'vdv_d07_4','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d07.4@vtms.vn','093007004',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10075,'vdv_d07_5','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d07.5@vtms.vn','093007005',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10076,'vdv_d07_6','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d07.6@vtms.vn','093007006',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10081,'vdv_d08_1','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d08.1@vtms.vn','093008001',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10082,'vdv_d08_2','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d08.2@vtms.vn','093008002',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10083,'vdv_d08_3','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d08.3@vtms.vn','093008003',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10084,'vdv_d08_4','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d08.4@vtms.vn','093008004',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10085,'vdv_d08_5','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d08.5@vtms.vn','093008005',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10086,'vdv_d08_6','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d08.6@vtms.vn','093008006',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10091,'vdv_d09_1','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d09.1@vtms.vn','093009001',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10092,'vdv_d09_2','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d09.2@vtms.vn','093009002',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10093,'vdv_d09_3','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d09.3@vtms.vn','093009003',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10094,'vdv_d09_4','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d09.4@vtms.vn','093009004',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10095,'vdv_d09_5','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d09.5@vtms.vn','093009005',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10096,'vdv_d09_6','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d09.6@vtms.vn','093009006',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10101,'vdv_d10_1','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d10.1@vtms.vn','093010001',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10102,'vdv_d10_2','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d10.2@vtms.vn','093010002',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10103,'vdv_d10_3','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d10.3@vtms.vn','093010003',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10104,'vdv_d10_4','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d10.4@vtms.vn','093010004',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10105,'vdv_d10_5','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d10.5@vtms.vn','093010005',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10106,'vdv_d10_6','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d10.6@vtms.vn','093010006',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10111,'vdv_d11_1','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d11.1@vtms.vn','093011001',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10112,'vdv_d11_2','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d11.2@vtms.vn','093011002',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10113,'vdv_d11_3','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d11.3@vtms.vn','093011003',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10114,'vdv_d11_4','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d11.4@vtms.vn','093011004',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10115,'vdv_d11_5','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d11.5@vtms.vn','093011005',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10116,'vdv_d11_6','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d11.6@vtms.vn','093011006',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10121,'vdv_d12_1','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d12.1@vtms.vn','093012001',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10122,'vdv_d12_2','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d12.2@vtms.vn','093012002',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10123,'vdv_d12_3','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d12.3@vtms.vn','093012003',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10124,'vdv_d12_4','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d12.4@vtms.vn','093012004',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10125,'vdv_d12_5','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d12.5@vtms.vn','093012005',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10126,'vdv_d12_6','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d12.6@vtms.vn','093012006',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10131,'vdv_d13_1','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d13.1@vtms.vn','093013001',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10132,'vdv_d13_2','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d13.2@vtms.vn','093013002',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10133,'vdv_d13_3','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d13.3@vtms.vn','093013003',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10134,'vdv_d13_4','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d13.4@vtms.vn','093013004',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10135,'vdv_d13_5','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d13.5@vtms.vn','093013005',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10136,'vdv_d13_6','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d13.6@vtms.vn','093013006',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10141,'vdv_d14_1','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d14.1@vtms.vn','093014001',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10142,'vdv_d14_2','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d14.2@vtms.vn','093014002',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10143,'vdv_d14_3','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d14.3@vtms.vn','093014003',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10144,'vdv_d14_4','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d14.4@vtms.vn','093014004',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10145,'vdv_d14_5','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d14.5@vtms.vn','093014005',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10146,'vdv_d14_6','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d14.6@vtms.vn','093014006',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10151,'vdv_d15_1','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d15.1@vtms.vn','093015001',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10152,'vdv_d15_2','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d15.2@vtms.vn','093015002',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10153,'vdv_d15_3','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d15.3@vtms.vn','093015003',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10154,'vdv_d15_4','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d15.4@vtms.vn','093015004',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10155,'vdv_d15_5','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d15.5@vtms.vn','093015005',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10156,'vdv_d15_6','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d15.6@vtms.vn','093015006',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10161,'vdv_d16_1','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d16.1@vtms.vn','093016001',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10162,'vdv_d16_2','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d16.2@vtms.vn','093016002',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10163,'vdv_d16_3','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d16.3@vtms.vn','093016003',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10164,'vdv_d16_4','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d16.4@vtms.vn','093016004',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10165,'vdv_d16_5','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d16.5@vtms.vn','093016005',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10166,'vdv_d16_6','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d16.6@vtms.vn','093016006',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10171,'vdv_d17_1','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d17.1@vtms.vn','093017001',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10172,'vdv_d17_2','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d17.2@vtms.vn','093017002',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10173,'vdv_d17_3','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d17.3@vtms.vn','093017003',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10174,'vdv_d17_4','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d17.4@vtms.vn','093017004',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10175,'vdv_d17_5','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d17.5@vtms.vn','093017005',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10176,'vdv_d17_6','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d17.6@vtms.vn','093017006',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10181,'vdv_d18_1','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d18.1@vtms.vn','093018001',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10182,'vdv_d18_2','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d18.2@vtms.vn','093018002',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10183,'vdv_d18_3','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d18.3@vtms.vn','093018003',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10184,'vdv_d18_4','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d18.4@vtms.vn','093018004',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10185,'vdv_d18_5','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d18.5@vtms.vn','093018005',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10186,'vdv_d18_6','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d18.6@vtms.vn','093018006',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10191,'vdv_d19_1','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d19.1@vtms.vn','093019001',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10192,'vdv_d19_2','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d19.2@vtms.vn','093019002',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10193,'vdv_d19_3','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d19.3@vtms.vn','093019003',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10194,'vdv_d19_4','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d19.4@vtms.vn','093019004',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10195,'vdv_d19_5','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d19.5@vtms.vn','093019005',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10196,'vdv_d19_6','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d19.6@vtms.vn','093019006',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10201,'vdv_d20_1','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d20.1@vtms.vn','093020001',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10202,'vdv_d20_2','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d20.2@vtms.vn','093020002',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10203,'vdv_d20_3','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d20.3@vtms.vn','093020003',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10204,'vdv_d20_4','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d20.4@vtms.vn','093020004',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10205,'vdv_d20_5','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d20.5@vtms.vn','093020005',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10206,'vdv_d20_6','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d20.6@vtms.vn','093020006',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10211,'vdv_d21_1','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d21.1@vtms.vn','093021001',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10212,'vdv_d21_2','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d21.2@vtms.vn','093021002',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10213,'vdv_d21_3','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d21.3@vtms.vn','093021003',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10214,'vdv_d21_4','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d21.4@vtms.vn','093021004',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10215,'vdv_d21_5','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d21.5@vtms.vn','093021005',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10216,'vdv_d21_6','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d21.6@vtms.vn','093021006',5,'HOAT_DONG','2026-05-22 13:39:43',NULL),(10221,'vdv_d22_1','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d22.1@vtms.vn','093022001',5,'HOAT_DONG','2026-05-22 13:50:53',NULL),(10222,'vdv_d22_2','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d22.2@vtms.vn','093022002',5,'HOAT_DONG','2026-05-22 13:50:53',NULL),(10223,'vdv_d22_3','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d22.3@vtms.vn','093022003',5,'HOAT_DONG','2026-05-22 13:50:53',NULL),(10224,'vdv_d22_4','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d22.4@vtms.vn','093022004',5,'HOAT_DONG','2026-05-22 13:50:53',NULL),(10225,'vdv_d22_5','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d22.5@vtms.vn','093022005',5,'HOAT_DONG','2026-05-22 13:50:53',NULL),(10226,'vdv_d22_6','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d22.6@vtms.vn','093022006',5,'HOAT_DONG','2026-05-22 13:50:53',NULL),(10231,'vdv_d23_1','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d23.1@vtms.vn','093023001',5,'HOAT_DONG','2026-05-22 16:35:13',NULL),(10232,'vdv_d23_2','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d23.2@vtms.vn','093023002',5,'HOAT_DONG','2026-05-22 16:35:13',NULL),(10233,'vdv_d23_3','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d23.3@vtms.vn','093023003',5,'HOAT_DONG','2026-05-22 16:35:13',NULL),(10234,'vdv_d23_4','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d23.4@vtms.vn','093023004',5,'HOAT_DONG','2026-05-22 16:35:13',NULL),(10235,'vdv_d23_5','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d23.5@vtms.vn','093023005',5,'HOAT_DONG','2026-05-22 16:35:13',NULL),(10236,'vdv_d23_6','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d23.6@vtms.vn','093023006',5,'HOAT_DONG','2026-05-22 16:35:13',NULL),(10241,'vdv_d24_1','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d24.1@vtms.vn','093024001',5,'HOAT_DONG','2026-05-22 16:35:13',NULL),(10242,'vdv_d24_2','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d24.2@vtms.vn','093024002',5,'HOAT_DONG','2026-05-22 16:35:13',NULL),(10243,'vdv_d24_3','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d24.3@vtms.vn','093024003',5,'HOAT_DONG','2026-05-22 16:35:13',NULL),(10244,'vdv_d24_4','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d24.4@vtms.vn','093024004',5,'HOAT_DONG','2026-05-22 16:35:13',NULL),(10245,'vdv_d24_5','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d24.5@vtms.vn','093024005',5,'HOAT_DONG','2026-05-22 16:35:13',NULL),(10246,'vdv_d24_6','$2y$10$lhie2aWTc.wTcNfXCgIWJOWHajLAj/IsjZwMNKrZMZl0Nsk6VeIf.','vdv.d24.6@vtms.vn','093024006',5,'HOAT_DONG','2026-05-22 16:35:13',NULL);
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
INSERT INTO `thanhtichdoibong` VALUES (1,1,101,NULL,NULL,NULL,3,20,2026,1,'VO_DICH','2026-04-03','BTC_NHAP_TAY','Đội cấp xã/phường vô địch giải cơ sở trong dữ liệu mẫu.','HOP_LE','2026-05-22 10:47:00',NULL),(2,3,102,NULL,NULL,NULL,2,2,2026,1,'VO_DICH','2026-05-05','BTC_NHAP_TAY','Đội tỉnh/thành vô địch giải cấp tỉnh trong dữ liệu mẫu.','HOP_LE','2026-05-22 10:47:00',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=10247 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `thanhviendoibong`
--

LOCK TABLES `thanhviendoibong` WRITE;
/*!40000 ALTER TABLE `thanhviendoibong` DISABLE KEYS */;
INSERT INTO `thanhviendoibong` VALUES (10011,1,10011,'DOI_TRUONG','DANG_THAM_GIA','2026-01-01',NULL),(10012,1,10012,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10013,1,10013,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10014,1,10014,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10015,1,10015,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10016,1,10016,'DU_BI','DANG_THAM_GIA','2026-01-01',NULL),(10021,2,10021,'DOI_TRUONG','DANG_THAM_GIA','2026-01-01',NULL),(10022,2,10022,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10023,2,10023,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10024,2,10024,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10025,2,10025,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10026,2,10026,'DU_BI','DANG_THAM_GIA','2026-01-01',NULL),(10031,3,10031,'DOI_TRUONG','DANG_THAM_GIA','2026-01-01',NULL),(10032,3,10032,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10033,3,10033,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10034,3,10034,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10035,3,10035,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10036,3,10036,'DU_BI','DANG_THAM_GIA','2026-01-01',NULL),(10041,4,10041,'DOI_TRUONG','DANG_THAM_GIA','2026-01-01',NULL),(10042,4,10042,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10043,4,10043,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10044,4,10044,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10045,4,10045,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10046,4,10046,'DU_BI','DANG_THAM_GIA','2026-01-01',NULL),(10051,5,10051,'DOI_TRUONG','DANG_THAM_GIA','2026-01-01',NULL),(10052,5,10052,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10053,5,10053,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10054,5,10054,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10055,5,10055,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10056,5,10056,'DU_BI','DANG_THAM_GIA','2026-01-01',NULL),(10061,6,10061,'DOI_TRUONG','DANG_THAM_GIA','2026-01-01',NULL),(10062,6,10062,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10063,6,10063,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10064,6,10064,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10065,6,10065,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10066,6,10066,'DU_BI','DANG_THAM_GIA','2026-01-01',NULL),(10071,7,10071,'DOI_TRUONG','DANG_THAM_GIA','2026-01-01',NULL),(10072,7,10072,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10073,7,10073,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10074,7,10074,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10075,7,10075,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10076,7,10076,'DU_BI','DANG_THAM_GIA','2026-01-01',NULL),(10081,8,10081,'DOI_TRUONG','DANG_THAM_GIA','2026-01-01',NULL),(10082,8,10082,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10083,8,10083,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10084,8,10084,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10085,8,10085,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10086,8,10086,'DU_BI','DANG_THAM_GIA','2026-01-01',NULL),(10091,9,10091,'DOI_TRUONG','DANG_THAM_GIA','2026-01-01',NULL),(10092,9,10092,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10093,9,10093,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10094,9,10094,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10095,9,10095,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10096,9,10096,'DU_BI','DANG_THAM_GIA','2026-01-01',NULL),(10101,10,10101,'DOI_TRUONG','DANG_THAM_GIA','2026-01-01',NULL),(10102,10,10102,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10103,10,10103,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10104,10,10104,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10105,10,10105,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10106,10,10106,'DU_BI','DANG_THAM_GIA','2026-01-01',NULL),(10111,11,10111,'DOI_TRUONG','DANG_THAM_GIA','2026-01-01',NULL),(10112,11,10112,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10113,11,10113,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10114,11,10114,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10115,11,10115,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10116,11,10116,'DU_BI','DANG_THAM_GIA','2026-01-01',NULL),(10121,12,10121,'DOI_TRUONG','DANG_THAM_GIA','2026-01-01',NULL),(10122,12,10122,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10123,12,10123,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10124,12,10124,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10125,12,10125,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10126,12,10126,'DU_BI','DANG_THAM_GIA','2026-01-01',NULL),(10131,13,10131,'DOI_TRUONG','DANG_THAM_GIA','2026-01-01',NULL),(10132,13,10132,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10133,13,10133,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10134,13,10134,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10135,13,10135,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10136,13,10136,'DU_BI','DANG_THAM_GIA','2026-01-01',NULL),(10141,14,10141,'DOI_TRUONG','DANG_THAM_GIA','2026-01-01',NULL),(10142,14,10142,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10143,14,10143,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10144,14,10144,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10145,14,10145,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10146,14,10146,'DU_BI','DANG_THAM_GIA','2026-01-01',NULL),(10151,15,10151,'DOI_TRUONG','DANG_THAM_GIA','2026-01-01',NULL),(10152,15,10152,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10153,15,10153,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10154,15,10154,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10155,15,10155,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10156,15,10156,'DU_BI','DANG_THAM_GIA','2026-01-01',NULL),(10161,16,10161,'DOI_TRUONG','DANG_THAM_GIA','2026-01-01',NULL),(10162,16,10162,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10163,16,10163,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10164,16,10164,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10165,16,10165,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10166,16,10166,'DU_BI','DANG_THAM_GIA','2026-01-01',NULL),(10171,17,10171,'DOI_TRUONG','DANG_THAM_GIA','2026-01-01',NULL),(10172,17,10172,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10173,17,10173,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10174,17,10174,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10175,17,10175,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10176,17,10176,'DU_BI','DANG_THAM_GIA','2026-01-01',NULL),(10181,18,10181,'DOI_TRUONG','DANG_THAM_GIA','2026-01-01',NULL),(10182,18,10182,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10183,18,10183,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10184,18,10184,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10185,18,10185,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10186,18,10186,'DU_BI','DANG_THAM_GIA','2026-01-01',NULL),(10191,19,10191,'DOI_TRUONG','DANG_THAM_GIA','2026-01-01',NULL),(10192,19,10192,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10193,19,10193,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10194,19,10194,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10195,19,10195,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10196,19,10196,'DU_BI','DANG_THAM_GIA','2026-01-01',NULL),(10201,20,10201,'DOI_TRUONG','DANG_THAM_GIA','2026-01-01',NULL),(10202,20,10202,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10203,20,10203,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10204,20,10204,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10205,20,10205,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10206,20,10206,'DU_BI','DANG_THAM_GIA','2026-01-01',NULL),(10211,21,10211,'DOI_TRUONG','DANG_THAM_GIA','2026-01-01',NULL),(10212,21,10212,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10213,21,10213,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10214,21,10214,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10215,21,10215,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10216,21,10216,'DU_BI','DANG_THAM_GIA','2026-01-01',NULL),(10221,22,10221,'DOI_TRUONG','DANG_THAM_GIA','2026-01-01',NULL),(10222,22,10222,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10223,22,10223,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10224,22,10224,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10225,22,10225,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10226,22,10226,'DU_BI','DANG_THAM_GIA','2026-01-01',NULL),(10231,23,10231,'DOI_TRUONG','DANG_THAM_GIA','2026-01-01',NULL),(10232,23,10232,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10233,23,10233,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10234,23,10234,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10235,23,10235,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10236,23,10236,'DU_BI','DANG_THAM_GIA','2026-01-01',NULL),(10241,24,10241,'DOI_TRUONG','DANG_THAM_GIA','2026-01-01',NULL),(10242,24,10242,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10243,24,10243,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10244,24,10244,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10245,24,10245,'THANH_VIEN','DANG_THAM_GIA','2026-01-01',NULL),(10246,24,10246,'DU_BI','DANG_THAM_GIA','2026-01-01',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=116 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `thethucgiaidau`
--

LOCK TABLES `thethucgiaidau` WRITE;
/*!40000 ALTER TABLE `thethucgiaidau` DISABLE KEYS */;
INSERT INTO `thethucgiaidau` VALUES (101,101,'Vòng loại trực tiếp',1,0,1,1,'HYBRID','BTC_NHAP_TAY','Thể thức mẫu cấp xã/phường.','DA_XAC_NHAN'),(102,102,'Vòng loại trực tiếp',1,0,1,1,'HYBRID','BTC_NHAP_TAY','Thể thức mẫu cấp tỉnh/thành.','DA_XAC_NHAN'),(103,103,'Vòng loại trực tiếp',1,0,1,1,'HYBRID','BTC_NHAP_TAY','Thể thức mẫu cấp quốc gia.','DA_XAC_NHAN'),(110,108,'Vòng loại trực tiếp',1,0,1,1,'HYBRID','BTC_NHAP_TAY',NULL,'DANG_THIET_LAP'),(115,109,'Vòng loại trực tiếp',1,0,1,1,'HYBRID','BTC_NHAP_TAY',NULL,'DANG_THIET_LAP');
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
) ENGINE=InnoDB AUTO_INCREMENT=71 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `thongbao`
--

LOCK TABLES `thongbao` WRITE;
/*!40000 ALTER TABLE `thongbao` DISABLE KEYS */;
INSERT INTO `thongbao` VALUES (9,6,'Giải đấu mới: Phuong Sai Gon 2026','Giải đấu Phuong Sai Gon 2026 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 14:47:57',NULL),(10,7,'Giải đấu mới: Phuong Sai Gon 2026','Giải đấu Phuong Sai Gon 2026 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 14:47:57',NULL),(11,8,'Giải đấu mới: Phuong Sai Gon 2026','Giải đấu Phuong Sai Gon 2026 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 14:47:57',NULL),(12,9,'Giải đấu mới: Phuong Sai Gon 2026','Giải đấu Phuong Sai Gon 2026 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 14:47:57',NULL),(13,20,'Giải đấu mới: Phuong Sai Gon 2026','Giải đấu Phuong Sai Gon 2026 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 14:47:57',NULL),(14,21,'Giải đấu mới: Phuong Sai Gon 2026','Giải đấu Phuong Sai Gon 2026 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 14:47:57',NULL),(15,22,'Giải đấu mới: Phuong Sai Gon 2026','Giải đấu Phuong Sai Gon 2026 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 14:47:57',NULL),(16,23,'Giải đấu mới: Phuong Sai Gon 2026','Giải đấu Phuong Sai Gon 2026 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 14:47:57',NULL),(17,24,'Giải đấu mới: Phuong Sai Gon 2026','Giải đấu Phuong Sai Gon 2026 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 14:47:57',NULL),(18,25,'Giải đấu mới: Phuong Sai Gon 2026','Giải đấu Phuong Sai Gon 2026 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 14:47:57',NULL),(19,26,'Giải đấu mới: Phuong Sai Gon 2026','Giải đấu Phuong Sai Gon 2026 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 14:47:57',NULL),(20,27,'Giải đấu mới: Phuong Sai Gon 2026','Giải đấu Phuong Sai Gon 2026 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 14:47:57',NULL),(21,28,'Giải đấu mới: Phuong Sai Gon 2026','Giải đấu Phuong Sai Gon 2026 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 14:47:57',NULL),(22,29,'Giải đấu mới: Phuong Sai Gon 2026','Giải đấu Phuong Sai Gon 2026 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 14:47:57',NULL),(23,30,'Giải đấu mới: Phuong Sai Gon 2026','Giải đấu Phuong Sai Gon 2026 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 14:47:57',NULL),(24,31,'Giải đấu mới: Phuong Sai Gon 2026','Giải đấu Phuong Sai Gon 2026 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 14:47:57',NULL),(25,32,'Giải đấu mới: Phuong Sai Gon 2026','Giải đấu Phuong Sai Gon 2026 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 14:47:57',NULL),(26,33,'Giải đấu mới: Phuong Sai Gon 2026','Giải đấu Phuong Sai Gon 2026 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 14:47:57',NULL),(27,34,'Giải đấu mới: Phuong Sai Gon 2026','Giải đấu Phuong Sai Gon 2026 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 14:47:57',NULL),(28,35,'Giải đấu mới: Phuong Sai Gon 2026','Giải đấu Phuong Sai Gon 2026 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 14:47:57',NULL),(29,36,'Giải đấu mới: Phuong Sai Gon 2026','Giải đấu Phuong Sai Gon 2026 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 14:47:57',NULL),(30,37,'Giải đấu mới: Phuong Sai Gon 2026','Giải đấu Phuong Sai Gon 2026 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 14:47:57',NULL),(40,6,'Giải đấu mới: P.SaiGon 2026-ver2','Giải đấu P.SaiGon 2026-ver2 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 16:40:59',NULL),(41,7,'Giải đấu mới: P.SaiGon 2026-ver2','Giải đấu P.SaiGon 2026-ver2 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 16:40:59',NULL),(42,8,'Giải đấu mới: P.SaiGon 2026-ver2','Giải đấu P.SaiGon 2026-ver2 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 16:40:59',NULL),(43,9,'Giải đấu mới: P.SaiGon 2026-ver2','Giải đấu P.SaiGon 2026-ver2 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 16:40:59',NULL),(44,20,'Giải đấu mới: P.SaiGon 2026-ver2','Giải đấu P.SaiGon 2026-ver2 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 16:40:59',NULL),(45,21,'Giải đấu mới: P.SaiGon 2026-ver2','Giải đấu P.SaiGon 2026-ver2 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 16:40:59',NULL),(46,22,'Giải đấu mới: P.SaiGon 2026-ver2','Giải đấu P.SaiGon 2026-ver2 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 16:40:59',NULL),(47,23,'Giải đấu mới: P.SaiGon 2026-ver2','Giải đấu P.SaiGon 2026-ver2 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 16:40:59',NULL),(48,24,'Giải đấu mới: P.SaiGon 2026-ver2','Giải đấu P.SaiGon 2026-ver2 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 16:40:59',NULL),(49,25,'Giải đấu mới: P.SaiGon 2026-ver2','Giải đấu P.SaiGon 2026-ver2 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 16:40:59',NULL),(50,26,'Giải đấu mới: P.SaiGon 2026-ver2','Giải đấu P.SaiGon 2026-ver2 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 16:40:59',NULL),(51,27,'Giải đấu mới: P.SaiGon 2026-ver2','Giải đấu P.SaiGon 2026-ver2 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 16:40:59',NULL),(52,28,'Giải đấu mới: P.SaiGon 2026-ver2','Giải đấu P.SaiGon 2026-ver2 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 16:40:59',NULL),(53,29,'Giải đấu mới: P.SaiGon 2026-ver2','Giải đấu P.SaiGon 2026-ver2 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 16:40:59',NULL),(54,30,'Giải đấu mới: P.SaiGon 2026-ver2','Giải đấu P.SaiGon 2026-ver2 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 16:40:59',NULL),(55,31,'Giải đấu mới: P.SaiGon 2026-ver2','Giải đấu P.SaiGon 2026-ver2 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 16:40:59',NULL),(56,32,'Giải đấu mới: P.SaiGon 2026-ver2','Giải đấu P.SaiGon 2026-ver2 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 16:40:59',NULL),(57,33,'Giải đấu mới: P.SaiGon 2026-ver2','Giải đấu P.SaiGon 2026-ver2 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 16:40:59',NULL),(58,34,'Giải đấu mới: P.SaiGon 2026-ver2','Giải đấu P.SaiGon 2026-ver2 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 16:40:59',NULL),(59,35,'Giải đấu mới: P.SaiGon 2026-ver2','Giải đấu P.SaiGon 2026-ver2 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 16:40:59',NULL),(60,36,'Giải đấu mới: P.SaiGon 2026-ver2','Giải đấu P.SaiGon 2026-ver2 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 16:40:59',NULL),(61,37,'Giải đấu mới: P.SaiGon 2026-ver2','Giải đấu P.SaiGon 2026-ver2 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 16:40:59',NULL),(62,38,'Giải đấu mới: P.SaiGon 2026-ver2','Giải đấu P.SaiGon 2026-ver2 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 16:40:59',NULL),(63,39,'Giải đấu mới: P.SaiGon 2026-ver2','Giải đấu P.SaiGon 2026-ver2 đã được công bố và mở đăng ký. Huấn luyện viên có đội đủ điều kiện có thể gửi hồ sơ tham gia.','HE_THONG','CHUA_DOC','2026-05-22 16:40:59',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trandau`
--

LOCK TABLES `trandau` WRITE;
/*!40000 ALTER TABLE `trandau` DISABLE KEYS */;
INSERT INTO `trandau` VALUES (20,109,13,NULL,NULL,'R13-20260522170845',NULL,'VONG_DIEM',1,2,NULL,12,'2026-05-22 17:13:18','2026-05-22 17:14:30',1,NULL,1,NULL,NULL,NULL,NULL,'DA_KET_THUC','2026-05-22 17:08:45','2026-05-22 17:14:30');
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
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trandauslot`
--

LOCK TABLES `trandauslot` WRITE;
/*!40000 ALTER TABLE `trandauslot` DISABLE KEYS */;
INSERT INTO `trandauslot` VALUES (41,20,1,NULL,'TEAM',1,NULL,NULL,NULL,NULL,NULL,NULL),(42,20,2,NULL,'TEAM',2,NULL,NULL,NULL,NULL,NULL,NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trongtai`
--

LOCK TABLES `trongtai` WRITE;
/*!40000 ALTER TABLE `trongtai` DISABLE KEYS */;
INSERT INTO `trongtai` VALUES (10,40,'Cấp xã/phường',6,'HOAT_DONG'),(11,41,'Cấp xã/phường',5,'HOAT_DONG'),(12,42,'Cấp xã/phường',4,'HOAT_DONG'),(13,43,'Cấp xã/phường',6,'HOAT_DONG'),(14,44,'Cấp xã/phường',5,'HOAT_DONG'),(15,45,'Cấp xã/phường',4,'HOAT_DONG'),(16,46,'Cấp xã/phường',6,'HOAT_DONG'),(17,47,'Cấp xã/phường',5,'HOAT_DONG'),(18,48,'Cấp xã/phường',4,'HOAT_DONG');
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
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trongtaitrandau`
--

LOCK TABLES `trongtaitrandau` WRITE;
/*!40000 ALTER TABLE `trongtaitrandau` DISABLE KEYS */;
INSERT INTO `trongtaitrandau` VALUES (17,20,10,'TRONG_TAI_CHINH',1,'2026-05-22 17:10:28'),(18,20,11,'TRONG_TAI_PHU',1,'2026-05-22 17:10:28'),(19,20,12,'GIAM_SAT',1,'2026-05-22 17:10:28');
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
) ENGINE=InnoDB AUTO_INCREMENT=10247 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vandongvien`
--

LOCK TABLES `vandongvien` WRITE;
/*!40000 ALTER TABLE `vandongvien` DISABLE KEYS */;
INSERT INTO `vandongvien` VALUES (10011,10011,'VDV-MAU-001-1',175.00,65.00,'CHU_CONG','DU_DIEU_KIEN'),(10012,10012,'VDV-MAU-001-2',176.00,66.00,'PHU_CONG','DU_DIEU_KIEN'),(10013,10013,'VDV-MAU-001-3',177.00,67.00,'CHUYEN_HAI','DU_DIEU_KIEN'),(10014,10014,'VDV-MAU-001-4',178.00,68.00,'DOI_CHUYEN','DU_DIEU_KIEN'),(10015,10015,'VDV-MAU-001-5',179.00,69.00,'LIBERO','DU_DIEU_KIEN'),(10016,10016,'VDV-MAU-001-6',180.00,70.00,'DOI_TRU','DU_DIEU_KIEN'),(10021,10021,'VDV-MAU-002-1',175.00,65.00,'CHU_CONG','DU_DIEU_KIEN'),(10022,10022,'VDV-MAU-002-2',176.00,66.00,'PHU_CONG','DU_DIEU_KIEN'),(10023,10023,'VDV-MAU-002-3',177.00,67.00,'CHUYEN_HAI','DU_DIEU_KIEN'),(10024,10024,'VDV-MAU-002-4',178.00,68.00,'DOI_CHUYEN','DU_DIEU_KIEN'),(10025,10025,'VDV-MAU-002-5',179.00,69.00,'LIBERO','DU_DIEU_KIEN'),(10026,10026,'VDV-MAU-002-6',180.00,70.00,'DOI_TRU','DU_DIEU_KIEN'),(10031,10031,'VDV-MAU-003-1',175.00,65.00,'CHU_CONG','DU_DIEU_KIEN'),(10032,10032,'VDV-MAU-003-2',176.00,66.00,'PHU_CONG','DU_DIEU_KIEN'),(10033,10033,'VDV-MAU-003-3',177.00,67.00,'CHUYEN_HAI','DU_DIEU_KIEN'),(10034,10034,'VDV-MAU-003-4',178.00,68.00,'DOI_CHUYEN','DU_DIEU_KIEN'),(10035,10035,'VDV-MAU-003-5',179.00,69.00,'LIBERO','DU_DIEU_KIEN'),(10036,10036,'VDV-MAU-003-6',180.00,70.00,'DOI_TRU','DU_DIEU_KIEN'),(10041,10041,'VDV-MAU-004-1',175.00,65.00,'CHU_CONG','DU_DIEU_KIEN'),(10042,10042,'VDV-MAU-004-2',176.00,66.00,'PHU_CONG','DU_DIEU_KIEN'),(10043,10043,'VDV-MAU-004-3',177.00,67.00,'CHUYEN_HAI','DU_DIEU_KIEN'),(10044,10044,'VDV-MAU-004-4',178.00,68.00,'DOI_CHUYEN','DU_DIEU_KIEN'),(10045,10045,'VDV-MAU-004-5',179.00,69.00,'LIBERO','DU_DIEU_KIEN'),(10046,10046,'VDV-MAU-004-6',180.00,70.00,'DOI_TRU','DU_DIEU_KIEN'),(10051,10051,'VDV-MAU-005-1',175.00,65.00,'CHU_CONG','DU_DIEU_KIEN'),(10052,10052,'VDV-MAU-005-2',176.00,66.00,'PHU_CONG','DU_DIEU_KIEN'),(10053,10053,'VDV-MAU-005-3',177.00,67.00,'CHUYEN_HAI','DU_DIEU_KIEN'),(10054,10054,'VDV-MAU-005-4',178.00,68.00,'DOI_CHUYEN','DU_DIEU_KIEN'),(10055,10055,'VDV-MAU-005-5',179.00,69.00,'LIBERO','DU_DIEU_KIEN'),(10056,10056,'VDV-MAU-005-6',180.00,70.00,'DOI_TRU','DU_DIEU_KIEN'),(10061,10061,'VDV-MAU-006-1',175.00,65.00,'CHU_CONG','DU_DIEU_KIEN'),(10062,10062,'VDV-MAU-006-2',176.00,66.00,'PHU_CONG','DU_DIEU_KIEN'),(10063,10063,'VDV-MAU-006-3',177.00,67.00,'CHUYEN_HAI','DU_DIEU_KIEN'),(10064,10064,'VDV-MAU-006-4',178.00,68.00,'DOI_CHUYEN','DU_DIEU_KIEN'),(10065,10065,'VDV-MAU-006-5',179.00,69.00,'LIBERO','DU_DIEU_KIEN'),(10066,10066,'VDV-MAU-006-6',180.00,70.00,'DOI_TRU','DU_DIEU_KIEN'),(10071,10071,'VDV-MAU-007-1',175.00,65.00,'CHU_CONG','DU_DIEU_KIEN'),(10072,10072,'VDV-MAU-007-2',176.00,66.00,'PHU_CONG','DU_DIEU_KIEN'),(10073,10073,'VDV-MAU-007-3',177.00,67.00,'CHUYEN_HAI','DU_DIEU_KIEN'),(10074,10074,'VDV-MAU-007-4',178.00,68.00,'DOI_CHUYEN','DU_DIEU_KIEN'),(10075,10075,'VDV-MAU-007-5',179.00,69.00,'LIBERO','DU_DIEU_KIEN'),(10076,10076,'VDV-MAU-007-6',180.00,70.00,'DOI_TRU','DU_DIEU_KIEN'),(10081,10081,'VDV-MAU-008-1',175.00,65.00,'CHU_CONG','DU_DIEU_KIEN'),(10082,10082,'VDV-MAU-008-2',176.00,66.00,'PHU_CONG','DU_DIEU_KIEN'),(10083,10083,'VDV-MAU-008-3',177.00,67.00,'CHUYEN_HAI','DU_DIEU_KIEN'),(10084,10084,'VDV-MAU-008-4',178.00,68.00,'DOI_CHUYEN','DU_DIEU_KIEN'),(10085,10085,'VDV-MAU-008-5',179.00,69.00,'LIBERO','DU_DIEU_KIEN'),(10086,10086,'VDV-MAU-008-6',180.00,70.00,'DOI_TRU','DU_DIEU_KIEN'),(10091,10091,'VDV-MAU-009-1',175.00,65.00,'CHU_CONG','DU_DIEU_KIEN'),(10092,10092,'VDV-MAU-009-2',176.00,66.00,'PHU_CONG','DU_DIEU_KIEN'),(10093,10093,'VDV-MAU-009-3',177.00,67.00,'CHUYEN_HAI','DU_DIEU_KIEN'),(10094,10094,'VDV-MAU-009-4',178.00,68.00,'DOI_CHUYEN','DU_DIEU_KIEN'),(10095,10095,'VDV-MAU-009-5',179.00,69.00,'LIBERO','DU_DIEU_KIEN'),(10096,10096,'VDV-MAU-009-6',180.00,70.00,'DOI_TRU','DU_DIEU_KIEN'),(10101,10101,'VDV-MAU-010-1',175.00,65.00,'CHU_CONG','DU_DIEU_KIEN'),(10102,10102,'VDV-MAU-010-2',176.00,66.00,'PHU_CONG','DU_DIEU_KIEN'),(10103,10103,'VDV-MAU-010-3',177.00,67.00,'CHUYEN_HAI','DU_DIEU_KIEN'),(10104,10104,'VDV-MAU-010-4',178.00,68.00,'DOI_CHUYEN','DU_DIEU_KIEN'),(10105,10105,'VDV-MAU-010-5',179.00,69.00,'LIBERO','DU_DIEU_KIEN'),(10106,10106,'VDV-MAU-010-6',180.00,70.00,'DOI_TRU','DU_DIEU_KIEN'),(10111,10111,'VDV-MAU-011-1',175.00,65.00,'CHU_CONG','DU_DIEU_KIEN'),(10112,10112,'VDV-MAU-011-2',176.00,66.00,'PHU_CONG','DU_DIEU_KIEN'),(10113,10113,'VDV-MAU-011-3',177.00,67.00,'CHUYEN_HAI','DU_DIEU_KIEN'),(10114,10114,'VDV-MAU-011-4',178.00,68.00,'DOI_CHUYEN','DU_DIEU_KIEN'),(10115,10115,'VDV-MAU-011-5',179.00,69.00,'LIBERO','DU_DIEU_KIEN'),(10116,10116,'VDV-MAU-011-6',180.00,70.00,'DOI_TRU','DU_DIEU_KIEN'),(10121,10121,'VDV-MAU-012-1',175.00,65.00,'CHU_CONG','DU_DIEU_KIEN'),(10122,10122,'VDV-MAU-012-2',176.00,66.00,'PHU_CONG','DU_DIEU_KIEN'),(10123,10123,'VDV-MAU-012-3',177.00,67.00,'CHUYEN_HAI','DU_DIEU_KIEN'),(10124,10124,'VDV-MAU-012-4',178.00,68.00,'DOI_CHUYEN','DU_DIEU_KIEN'),(10125,10125,'VDV-MAU-012-5',179.00,69.00,'LIBERO','DU_DIEU_KIEN'),(10126,10126,'VDV-MAU-012-6',180.00,70.00,'DOI_TRU','DU_DIEU_KIEN'),(10131,10131,'VDV-MAU-013-1',175.00,65.00,'CHU_CONG','DU_DIEU_KIEN'),(10132,10132,'VDV-MAU-013-2',176.00,66.00,'PHU_CONG','DU_DIEU_KIEN'),(10133,10133,'VDV-MAU-013-3',177.00,67.00,'CHUYEN_HAI','DU_DIEU_KIEN'),(10134,10134,'VDV-MAU-013-4',178.00,68.00,'DOI_CHUYEN','DU_DIEU_KIEN'),(10135,10135,'VDV-MAU-013-5',179.00,69.00,'LIBERO','DU_DIEU_KIEN'),(10136,10136,'VDV-MAU-013-6',180.00,70.00,'DOI_TRU','DU_DIEU_KIEN'),(10141,10141,'VDV-MAU-014-1',175.00,65.00,'CHU_CONG','DU_DIEU_KIEN'),(10142,10142,'VDV-MAU-014-2',176.00,66.00,'PHU_CONG','DU_DIEU_KIEN'),(10143,10143,'VDV-MAU-014-3',177.00,67.00,'CHUYEN_HAI','DU_DIEU_KIEN'),(10144,10144,'VDV-MAU-014-4',178.00,68.00,'DOI_CHUYEN','DU_DIEU_KIEN'),(10145,10145,'VDV-MAU-014-5',179.00,69.00,'LIBERO','DU_DIEU_KIEN'),(10146,10146,'VDV-MAU-014-6',180.00,70.00,'DOI_TRU','DU_DIEU_KIEN'),(10151,10151,'VDV-MAU-015-1',175.00,65.00,'CHU_CONG','DU_DIEU_KIEN'),(10152,10152,'VDV-MAU-015-2',176.00,66.00,'PHU_CONG','DU_DIEU_KIEN'),(10153,10153,'VDV-MAU-015-3',177.00,67.00,'CHUYEN_HAI','DU_DIEU_KIEN'),(10154,10154,'VDV-MAU-015-4',178.00,68.00,'DOI_CHUYEN','DU_DIEU_KIEN'),(10155,10155,'VDV-MAU-015-5',179.00,69.00,'LIBERO','DU_DIEU_KIEN'),(10156,10156,'VDV-MAU-015-6',180.00,70.00,'DOI_TRU','DU_DIEU_KIEN'),(10161,10161,'VDV-MAU-016-1',175.00,65.00,'CHU_CONG','DU_DIEU_KIEN'),(10162,10162,'VDV-MAU-016-2',176.00,66.00,'PHU_CONG','DU_DIEU_KIEN'),(10163,10163,'VDV-MAU-016-3',177.00,67.00,'CHUYEN_HAI','DU_DIEU_KIEN'),(10164,10164,'VDV-MAU-016-4',178.00,68.00,'DOI_CHUYEN','DU_DIEU_KIEN'),(10165,10165,'VDV-MAU-016-5',179.00,69.00,'LIBERO','DU_DIEU_KIEN'),(10166,10166,'VDV-MAU-016-6',180.00,70.00,'DOI_TRU','DU_DIEU_KIEN'),(10171,10171,'VDV-MAU-017-1',175.00,65.00,'CHU_CONG','DU_DIEU_KIEN'),(10172,10172,'VDV-MAU-017-2',176.00,66.00,'PHU_CONG','DU_DIEU_KIEN'),(10173,10173,'VDV-MAU-017-3',177.00,67.00,'CHUYEN_HAI','DU_DIEU_KIEN'),(10174,10174,'VDV-MAU-017-4',178.00,68.00,'DOI_CHUYEN','DU_DIEU_KIEN'),(10175,10175,'VDV-MAU-017-5',179.00,69.00,'LIBERO','DU_DIEU_KIEN'),(10176,10176,'VDV-MAU-017-6',180.00,70.00,'DOI_TRU','DU_DIEU_KIEN'),(10181,10181,'VDV-MAU-018-1',175.00,65.00,'CHU_CONG','DU_DIEU_KIEN'),(10182,10182,'VDV-MAU-018-2',176.00,66.00,'PHU_CONG','DU_DIEU_KIEN'),(10183,10183,'VDV-MAU-018-3',177.00,67.00,'CHUYEN_HAI','DU_DIEU_KIEN'),(10184,10184,'VDV-MAU-018-4',178.00,68.00,'DOI_CHUYEN','DU_DIEU_KIEN'),(10185,10185,'VDV-MAU-018-5',179.00,69.00,'LIBERO','DU_DIEU_KIEN'),(10186,10186,'VDV-MAU-018-6',180.00,70.00,'DOI_TRU','DU_DIEU_KIEN'),(10191,10191,'VDV-MAU-019-1',175.00,65.00,'CHU_CONG','DU_DIEU_KIEN'),(10192,10192,'VDV-MAU-019-2',176.00,66.00,'PHU_CONG','DU_DIEU_KIEN'),(10193,10193,'VDV-MAU-019-3',177.00,67.00,'CHUYEN_HAI','DU_DIEU_KIEN'),(10194,10194,'VDV-MAU-019-4',178.00,68.00,'DOI_CHUYEN','DU_DIEU_KIEN'),(10195,10195,'VDV-MAU-019-5',179.00,69.00,'LIBERO','DU_DIEU_KIEN'),(10196,10196,'VDV-MAU-019-6',180.00,70.00,'DOI_TRU','DU_DIEU_KIEN'),(10201,10201,'VDV-MAU-020-1',175.00,65.00,'CHU_CONG','DU_DIEU_KIEN'),(10202,10202,'VDV-MAU-020-2',176.00,66.00,'PHU_CONG','DU_DIEU_KIEN'),(10203,10203,'VDV-MAU-020-3',177.00,67.00,'CHUYEN_HAI','DU_DIEU_KIEN'),(10204,10204,'VDV-MAU-020-4',178.00,68.00,'DOI_CHUYEN','DU_DIEU_KIEN'),(10205,10205,'VDV-MAU-020-5',179.00,69.00,'LIBERO','DU_DIEU_KIEN'),(10206,10206,'VDV-MAU-020-6',180.00,70.00,'DOI_TRU','DU_DIEU_KIEN'),(10211,10211,'VDV-MAU-021-1',175.00,65.00,'CHU_CONG','DU_DIEU_KIEN'),(10212,10212,'VDV-MAU-021-2',176.00,66.00,'PHU_CONG','DU_DIEU_KIEN'),(10213,10213,'VDV-MAU-021-3',177.00,67.00,'CHUYEN_HAI','DU_DIEU_KIEN'),(10214,10214,'VDV-MAU-021-4',178.00,68.00,'DOI_CHUYEN','DU_DIEU_KIEN'),(10215,10215,'VDV-MAU-021-5',179.00,69.00,'LIBERO','DU_DIEU_KIEN'),(10216,10216,'VDV-MAU-021-6',180.00,70.00,'DOI_TRU','DU_DIEU_KIEN'),(10221,10221,'VDV-MAU-022-1',175.00,65.00,'CHU_CONG','DU_DIEU_KIEN'),(10222,10222,'VDV-MAU-022-2',176.00,66.00,'PHU_CONG','DU_DIEU_KIEN'),(10223,10223,'VDV-MAU-022-3',177.00,67.00,'CHUYEN_HAI','DU_DIEU_KIEN'),(10224,10224,'VDV-MAU-022-4',178.00,68.00,'DOI_CHUYEN','DU_DIEU_KIEN'),(10225,10225,'VDV-MAU-022-5',179.00,69.00,'LIBERO','DU_DIEU_KIEN'),(10226,10226,'VDV-MAU-022-6',180.00,70.00,'DOI_TRU','DU_DIEU_KIEN'),(10231,10231,'VDV-MAU-023-1',175.00,65.00,'CHU_CONG','DU_DIEU_KIEN'),(10232,10232,'VDV-MAU-023-2',176.00,66.00,'PHU_CONG','DU_DIEU_KIEN'),(10233,10233,'VDV-MAU-023-3',177.00,67.00,'CHUYEN_HAI','DU_DIEU_KIEN'),(10234,10234,'VDV-MAU-023-4',178.00,68.00,'DOI_CHUYEN','DU_DIEU_KIEN'),(10235,10235,'VDV-MAU-023-5',179.00,69.00,'LIBERO','DU_DIEU_KIEN'),(10236,10236,'VDV-MAU-023-6',180.00,70.00,'DOI_TRU','DU_DIEU_KIEN'),(10241,10241,'VDV-MAU-024-1',175.00,65.00,'CHU_CONG','DU_DIEU_KIEN'),(10242,10242,'VDV-MAU-024-2',176.00,66.00,'PHU_CONG','DU_DIEU_KIEN'),(10243,10243,'VDV-MAU-024-3',177.00,67.00,'CHUYEN_HAI','DU_DIEU_KIEN'),(10244,10244,'VDV-MAU-024-4',178.00,68.00,'DOI_CHUYEN','DU_DIEU_KIEN'),(10245,10245,'VDV-MAU-024-5',179.00,69.00,'LIBERO','DU_DIEU_KIEN'),(10246,10246,'VDV-MAU-024-6',180.00,70.00,'DOI_TRU','DU_DIEU_KIEN');
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
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vitrithidau`
--

LOCK TABLES `vitrithidau` WRITE;
/*!40000 ALTER TABLE `vitrithidau` DISABLE KEYS */;
INSERT INTO `vitrithidau` VALUES (6,'Cụm sân Trung tâm TDTT Phường Sài Gòn','TRUNG_TAM_THE_THAO',20,'Trung tâm TDTT Phường Sài Gòn, Phường Sài Gòn, Thành phố Hồ Chí Minh','Trung tâm TDTT Phường Sài Gòn, Phường Sài Gòn, Thành phố Hồ Chí Minh, Việt Nam',1200,NULL,NULL,NULL,NULL,NULL,'Cụm sân bóng chuyền dữ liệu mẫu của Trung tâm TDTT Phường Sài Gòn.','HOAT_DONG','2026-05-22 17:07:47',NULL),(7,'Cụm sân Trung tâm TDTT Phường Bến Thành','TRUNG_TAM_THE_THAO',21,'Trung tâm TDTT Phường Bến Thành, Phường Bến Thành, Thành phố Hồ Chí Minh','Trung tâm TDTT Phường Bến Thành, Phường Bến Thành, Thành phố Hồ Chí Minh, Việt Nam',1200,NULL,NULL,NULL,NULL,NULL,'Cụm sân bóng chuyền dữ liệu mẫu của Trung tâm TDTT Phường Bến Thành.','HOAT_DONG','2026-05-22 17:07:47',NULL),(8,'Cụm sân Trung tâm TDTT Phường Hoàn Kiếm','TRUNG_TAM_THE_THAO',30,'Trung tâm TDTT Phường Hoàn Kiếm, Phường Hoàn Kiếm, Thành phố Hà Nội','Trung tâm TDTT Phường Hoàn Kiếm, Phường Hoàn Kiếm, Thành phố Hà Nội, Việt Nam',1200,NULL,NULL,NULL,NULL,NULL,'Cụm sân bóng chuyền dữ liệu mẫu của Trung tâm TDTT Phường Hoàn Kiếm.','HOAT_DONG','2026-05-22 17:07:47',NULL),(9,'Cụm sân Trung tâm HL và thi đấu TDTT Thành phố Hồ Chí Minh','TRUNG_TAM_THE_THAO',2,'Trung tâm huấn luyện và thi đấu TDTT Thành phố Hồ Chí Minh','Trung tâm huấn luyện và thi đấu TDTT Thành phố Hồ Chí Minh, Việt Nam',7200,NULL,NULL,NULL,NULL,NULL,'Cụm sân bóng chuyền dữ liệu mẫu của Trung tâm huấn luyện và thi đấu TDTT Thành phố Hồ Chí Minh.','HOAT_DONG','2026-05-22 17:07:47',NULL),(10,'Cụm sân Trung tâm HL và thi đấu TDTT Thành phố Hà Nội','TRUNG_TAM_THE_THAO',3,'Trung tâm huấn luyện và thi đấu TDTT Thành phố Hà Nội','Trung tâm huấn luyện và thi đấu TDTT Thành phố Hà Nội, Việt Nam',7200,NULL,NULL,NULL,NULL,NULL,'Cụm sân bóng chuyền dữ liệu mẫu của Trung tâm huấn luyện và thi đấu TDTT Thành phố Hà Nội.','HOAT_DONG','2026-05-22 17:07:47',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vongdau`
--

LOCK TABLES `vongdau` WRITE;
/*!40000 ALTER TABLE `vongdau` DISABLE KEYS */;
INSERT INTO `vongdau` VALUES (9,108,'Vòng loại trực tiếp','VONG_LOAI',1,NULL,NULL,8,0,0,NULL,1,NULL,NULL,'THANG_DI_TIEP','HYBRID','MANUAL',0,1,'DIEM_TRUNG_BINH','BTC_NHAP_TAY',1,'NHAP','2026-05-22 14:47:55',NULL),(13,109,'Vòng loại trực tiếp','VONG_LOAI',1,NULL,NULL,2,0,0,NULL,1,NULL,NULL,'THANG_DI_TIEP','HYBRID','MANUAL',0,1,'DIEM_TRUNG_BINH','BTC_NHAP_TAY',1,'NHAP','2026-05-22 16:58:57','2026-05-22 17:08:45');
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
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `yeucauxacnhan`
--

LOCK TABLES `yeucauxacnhan` WRITE;
/*!40000 ALTER TABLE `yeucauxacnhan` DISABLE KEYS */;
INSERT INTO `yeucauxacnhan` VALUES (14,'HUAN_LUYEN_VIEN',5,'BAN_TO_CHUC',3,'XAC_NHAN_DANG_KY_GIAI','Dang ky giai dau #108, doi #5. Yeu cau xac nhan doi Đội TDTT Phường Sài Gòn 02 tham gia giai dau Phuong Sai Gon 2026','DA_DUYET','2026-05-22 14:55:31','2026-05-22 14:55:37','Duyet dang ky doi bong'),(15,'HUAN_LUYEN_VIEN',1,'BAN_TO_CHUC',3,'XAC_NHAN_DANG_KY_GIAI','Dang ky giai dau #109, doi #1. Yeu cau xac nhan doi Đội Trung tâm TDTT Phường Sài Gòn tham gia giai dau P.SaiGon 2026-ver2','DA_DUYET','2026-05-22 16:42:04','2026-05-22 16:43:36','Duyet dang ky doi bong'),(16,'HUAN_LUYEN_VIEN',2,'BAN_TO_CHUC',3,'XAC_NHAN_DANG_KY_GIAI','Dang ky giai dau #109, doi #2. Yeu cau xac nhan doi Đội Tư nhân Phường Sài Gòn tham gia giai dau P.SaiGon 2026-ver2','DA_DUYET','2026-05-22 16:42:32','2026-05-22 16:43:36','Duyet dang ky doi bong');
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

-- Dump completed on 2026-05-22 23:00:21
