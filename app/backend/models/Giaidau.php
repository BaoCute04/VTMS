<?php

declare(strict_types=1);

namespace App\Backend\Models;

use App\Backend\Core\Model;
use Throwable;

final class Giaidau extends Model
{
    public function findOrganizerByAccountId(int $accountId): ?array
    {
        return $this->first(
            "SELECT
                btc.idbantochuc,
                btc.idnguoidung,
                btc.idcapbantochuc,
                btc.idkhuvucquanly,
                btc.idbantochuccha,
                btc.donvi,
                btc.chucvu,
                btc.trangthai,
                cbtc.macapbantochuc,
                cbtc.tencapbantochuc,
                cbtc.capkhuvucquanly,
                kv.makhuvuc AS makhuvucquanly,
                kv.tenkhuvuc AS tenkhuvucquanly,
                kv.capkhuvuc AS capkhuvucquanly_thucte,
                tk.idtaikhoan,
                tk.username,
                nd.hodem,
                nd.ten,
                TRIM(CONCAT(COALESCE(nd.hodem, ''), ' ', COALESCE(nd.ten, ''))) AS hoten
             FROM Bantochuc btc
             JOIN Capbantochuc cbtc ON cbtc.idcapbantochuc = btc.idcapbantochuc
             JOIN Khuvuc kv ON kv.idkhuvuc = btc.idkhuvucquanly
             JOIN Nguoidung nd ON nd.idnguoidung = btc.idnguoidung
             JOIN Taikhoan tk ON tk.idtaikhoan = nd.idtaikhoan
             WHERE tk.idtaikhoan = :account_id
             LIMIT 1",
            ['account_id' => $accountId]
        );
    }

    public function coachByAccountId(int $accountId): ?array
    {
        return $this->first(
            "SELECT
                hlv.idhuanluyenvien,
                hlv.idnguoidung,
                hlv.bangcap,
                hlv.kinhnghiem,
                hlv.trangthai,
                tk.idtaikhoan,
                tk.username,
                tk.email,
                tk.trangthai AS trangthai_taikhoan,
                nd.hodem,
                nd.ten,
                TRIM(CONCAT(COALESCE(nd.hodem, ''), ' ', COALESCE(nd.ten, ''))) AS hoten
             FROM Huanluyenvien hlv
             JOIN Nguoidung nd ON nd.idnguoidung = hlv.idnguoidung
             JOIN Taikhoan tk ON tk.idtaikhoan = nd.idtaikhoan
             WHERE tk.idtaikhoan = :account_id
             LIMIT 1",
            ['account_id' => $accountId]
        );
    }

    public function teamForCoach(int $coachId, int $teamId): ?array
    {
        return $this->first(
            "SELECT
                db.iddoibong,
                db.tendoibong,
                db.logo,
                db.diaphuong,
                db.mota,
                db.idhuanluyenvien,
                db.trangthai,
                db.ngaytao,
                db.ngaycapnhat,
                COALESCE(tv.total_members, 0) AS total_members,
                COALESCE(tv.active_members, 0) AS active_members
             FROM Doibong db
             LEFT JOIN (
                SELECT
                    iddoibong,
                    COUNT(*) AS total_members,
                    SUM(CASE WHEN trangthai = 'DANG_THAM_GIA' THEN 1 ELSE 0 END) AS active_members
                FROM Thanhviendoibong
                GROUP BY iddoibong
             ) tv ON tv.iddoibong = db.iddoibong
             WHERE db.iddoibong = :team_id
               AND db.idhuanluyenvien = :coach_id
             LIMIT 1",
            [
                'team_id' => $teamId,
                'coach_id' => $coachId,
            ]
        );
    }

    public function openTournamentsForCoach(int $coachId, array $filters = []): array
    {
        $where = [
            "gd.trangthai = 'DA_CONG_BO'",
            "gd.trangthaidangky = 'DANG_MO'",
        ];
        $bindings = [
            'coach_id' => $coachId,
        ];

        if (($filters['q'] ?? '') !== '') {
            $where[] = "CONCAT_WS(' ', gd.tengiaidau, gd.ghichu_diadiem, gd.mota, kv.tenkhuvuc) LIKE :keyword";
            $bindings['keyword'] = '%' . $filters['q'] . '%';
        }

        if (($filters['from'] ?? '') !== '') {
            $where[] = 'DATE(gd.thoigianbatdau) >= :from_date';
            $bindings['from_date'] = $filters['from'];
        }

        if (($filters['to'] ?? '') !== '') {
            $where[] = 'DATE(gd.thoigianbatdau) <= :to_date';
            $bindings['to_date'] = $filters['to'];
        }

        $statement = $this->db()->prepare(
            "SELECT
                gd.idgiaidau,
                gd.tengiaidau,
                gd.mota,
                gd.thoigianbatdau,
                gd.thoigianketthuc,
                gd.ghichu_diadiem AS diadiem,
                gd.ghichu_diadiem,
                kv.tenkhuvuc AS tenkhuvuc_phamvi,
                COALESCE(dl.so_doi_toi_da, gd.quymo) AS quymo,
                gd.hinhanh,
                gd.trangthai,
                gd.trangthaidangky,
                gd.idbantochuc,
                gd.ngaytao,
                gd.ngaycapnhat,
                btc.donvi AS bantochuc_donvi,
                dl.tieude AS dieule_tieude,
                dl.noidung AS dieule_noidung,
                dl.filedinhkem AS dieule_filedinhkem,
                COALESCE(reg.approved_registrations, 0) AS approved_registrations,
                COALESCE(my_reg.my_registration_count, 0) AS my_registration_count,
                COALESCE(my_reg.my_pending_count, 0) AS my_pending_count,
                COALESCE(my_reg.my_approved_count, 0) AS my_approved_count
             FROM Giaidau gd
             JOIN Bantochuc btc ON btc.idbantochuc = gd.idbantochuc
             JOIN Khuvuc kv ON kv.idkhuvuc = gd.idkhuvucphamvi
             LEFT JOIN Dieulegiaidau dl ON dl.idgiaidau = gd.idgiaidau
             LEFT JOIN (
                SELECT idgiaidau, COUNT(*) AS approved_registrations
                FROM Dangkygiaidau
                WHERE trangthai = 'DA_DUYET'
                GROUP BY idgiaidau
             ) reg ON reg.idgiaidau = gd.idgiaidau
             LEFT JOIN (
                SELECT
                    idgiaidau,
                    COUNT(*) AS my_registration_count,
                    SUM(CASE WHEN trangthai = 'CHO_DUYET' THEN 1 ELSE 0 END) AS my_pending_count,
                    SUM(CASE WHEN trangthai = 'DA_DUYET' THEN 1 ELSE 0 END) AS my_approved_count
                FROM Dangkygiaidau
                WHERE idhuanluyenvien = :coach_id
                GROUP BY idgiaidau
             ) my_reg ON my_reg.idgiaidau = gd.idgiaidau
             WHERE " . implode(' AND ', $where) . "
             ORDER BY gd.thoigianbatdau ASC, gd.idgiaidau DESC"
        );

        $statement->execute($bindings);

        return $statement->fetchAll();
    }

    public function existsByNameAndStartDate(string $name, string $startDate, ?int $excludeTournamentId = null): bool
    {
        $bindings = [
            'name' => $name,
            'start_date' => $startDate,
        ];

        $sql = "SELECT 1
             FROM Giaidau
             WHERE tengiaidau = :name
               AND thoigianbatdau = :start_date";

        if ($excludeTournamentId !== null) {
            $sql .= ' AND idgiaidau <> :exclude_tournament_id';
            $bindings['exclude_tournament_id'] = $excludeTournamentId;
        }

        $sql .= ' LIMIT 1';

        return $this->first(
            $sql,
            $bindings
        ) !== null;
    }

    public function listForOrganizer(int $organizerId, array $filters = []): array
    {
        $where = ['gd.idbantochuc = :organizer_id'];
        $bindings = ['organizer_id' => $organizerId];

        if (($filters['q'] ?? '') !== '') {
            $where[] = '(gd.tengiaidau LIKE :keyword OR gd.mota LIKE :keyword OR gd.ghichu_diadiem LIKE :keyword OR cg.tencapgiaidau LIKE :keyword OR kv.tenkhuvuc LIKE :keyword)';
            $bindings['keyword'] = '%' . $filters['q'] . '%';
        }

        if (($filters['status'] ?? '') !== '') {
            $where[] = 'gd.trangthai = :status';
            $bindings['status'] = $filters['status'];
        }

        if (($filters['registration_status'] ?? '') !== '') {
            $where[] = 'gd.trangthaidangky = :registration_status';
            $bindings['registration_status'] = $filters['registration_status'];
        }

        if (($filters['from'] ?? '') !== '') {
            $where[] = 'gd.thoigianbatdau >= :from_date';
            $bindings['from_date'] = $filters['from'];
        }

        if (($filters['to'] ?? '') !== '') {
            $where[] = 'gd.thoigianbatdau <= :to_date';
            $bindings['to_date'] = $filters['to'];
        }

        $statement = $this->db()->prepare(
            "SELECT
                gd.idgiaidau,
                gd.tengiaidau,
                gd.mota,
                gd.idcapgiaidau,
                cg.macapgiaidau,
                cg.tencapgiaidau,
                cg.capkhuvucphamvi,
                cg.capdoituongthamgia,
                gd.idkhuvucphamvi,
                kv.makhuvuc AS makhuvuc_phamvi,
                kv.tenkhuvuc AS tenkhuvuc_phamvi,
                kv.capkhuvuc AS capkhuvuc_phamvi,
                gd.idluat,
                lt.tenluat,
                lt.kieu_tran,
                gd.thoigianbatdau,
                gd.thoigianketthuc,
                COALESCE(dl.so_doi_toi_da, gd.quymo) AS quymo,
                gd.hinhanh,
                gd.tinhchat,
                gd.trangthai,
                gd.trangthaidangky,
                gd.trangthaithietlap,
                gd.ghichu_diadiem,
                gd.idbantochuc,
                gd.ngaytao,
                gd.ngaycapnhat,
                COALESCE(reg.total_dangky, 0) AS total_dangky,
                COALESCE(reg.cho_duyet, 0) AS dangky_cho_duyet,
                COALESCE(reg.da_duyet, 0) AS dangky_da_duyet,
                COALESCE(reg.tu_choi, 0) AS dangky_tu_choi,
                COALESCE(reg.da_huy, 0) AS dangky_da_huy
             FROM Giaidau gd
             JOIN Capgiaidau cg ON cg.idcapgiaidau = gd.idcapgiaidau
             JOIN Khuvuc kv ON kv.idkhuvuc = gd.idkhuvucphamvi
             JOIN Luatthidau lt ON lt.idluat = gd.idluat
             LEFT JOIN Dieulegiaidau dl ON dl.idgiaidau = gd.idgiaidau
             LEFT JOIN (
                SELECT
                    idgiaidau,
                    COUNT(*) AS total_dangky,
                    SUM(CASE WHEN trangthai = 'CHO_DUYET' THEN 1 ELSE 0 END) AS cho_duyet,
                    SUM(CASE WHEN trangthai = 'DA_DUYET' THEN 1 ELSE 0 END) AS da_duyet,
                    SUM(CASE WHEN trangthai = 'TU_CHOI' THEN 1 ELSE 0 END) AS tu_choi,
                    SUM(CASE WHEN trangthai = 'DA_HUY' THEN 1 ELSE 0 END) AS da_huy
                FROM Dangkygiaidau
                GROUP BY idgiaidau
             ) reg ON reg.idgiaidau = gd.idgiaidau
             WHERE " . implode(' AND ', $where) . "
             ORDER BY gd.ngaytao DESC, gd.idgiaidau DESC"
        );

        $statement->execute($bindings);

        return $statement->fetchAll();
    }

    public function competitionLocations(int $organizerId, array $filters = []): array
    {
        $organizer = $this->organizerById($organizerId);
        $where = ["vt.trangthai = 'HOAT_DONG'"];
        $bindings = [];

        if ($organizer !== null) {
            $where[] = 'fn_khuvuc_la_con(vt.idkhuvuc, :scope_id) = 1';
            $bindings['scope_id'] = (int) $organizer['idkhuvucquanly'];
        }

        if (($filters['status'] ?? '') !== '') {
            $where[] = 'vt.trangthai = :status';
            $bindings['status'] = $filters['status'];
        }

        if (($filters['q'] ?? '') !== '') {
            $where[] = "(vt.tenvitrithidau LIKE :keyword OR vt.diachi LIKE :keyword OR kv.tenkhuvuc LIKE :keyword)";
            $bindings['keyword'] = '%' . $filters['q'] . '%';
        }

        $statement = $this->db()->prepare(
            "SELECT
                vt.idvitrithidau,
                vt.tenvitrithidau,
                vt.idkhuvuc,
                kv.tenkhuvuc,
                kv.capkhuvuc,
                vt.diachi,
                vt.mota,
                vt.trangthai,
                s.ngaytao,
                s.ngaycapnhat,
                COALESCE(s.total_sandau, 0) AS total_sandau,
                COALESCE(s.active_sandau, 0) AS active_sandau
             FROM Vitrithidau vt
             JOIN Khuvuc kv ON kv.idkhuvuc = vt.idkhuvuc
             LEFT JOIN (
                SELECT
                    idvitrithidau,
                    COUNT(*) AS total_sandau,
                    SUM(CASE WHEN trangthai = 'HOAT_DONG' THEN 1 ELSE 0 END) AS active_sandau,
                    MIN(ngaytao) AS ngaytao,
                    MAX(ngaycapnhat) AS ngaycapnhat
                FROM Sandau
                WHERE idvitrithidau IS NOT NULL
                GROUP BY idvitrithidau
             ) s ON s.idvitrithidau = vt.idvitrithidau
             WHERE " . implode(' AND ', $where) . "
             ORDER BY vt.tenvitrithidau ASC, vt.idvitrithidau ASC"
        );

        $statement->execute($bindings);

        return $statement->fetchAll();
    }

    public function competitionLocationById(int $locationId, int $organizerId): ?array
    {
        $organizer = $this->organizerById($organizerId);

        if ($organizer === null) {
            return null;
        }

        return $this->first(
            "SELECT
                vt.idvitrithidau,
                vt.tenvitrithidau,
                vt.idkhuvuc,
                kv.tenkhuvuc,
                kv.capkhuvuc,
                vt.diachi,
                vt.mota,
                vt.trangthai
             FROM Vitrithidau vt
             JOIN Khuvuc kv ON kv.idkhuvuc = vt.idkhuvuc
             WHERE vt.idvitrithidau = :location_id
               AND vt.trangthai = 'HOAT_DONG'
               AND fn_khuvuc_la_con(vt.idkhuvuc, :scope_id) = 1
             LIMIT 1",
            [
                'location_id' => $locationId,
                'scope_id' => (int) $organizer['idkhuvucquanly'],
            ]
        );
    }

    public function organizerById(int $organizerId): ?array
    {
        return $this->first(
            "SELECT
                btc.idbantochuc,
                btc.idcapbantochuc,
                btc.idkhuvucquanly,
                btc.trangthai,
                cbtc.macapbantochuc,
                cbtc.tencapbantochuc,
                cbtc.capkhuvucquanly,
                kv.tenkhuvuc AS tenkhuvucquanly,
                kv.capkhuvuc AS capkhuvucquanly_thucte
             FROM Bantochuc btc
             JOIN Capbantochuc cbtc ON cbtc.idcapbantochuc = btc.idcapbantochuc
             JOIN Khuvuc kv ON kv.idkhuvuc = btc.idkhuvucquanly
             WHERE btc.idbantochuc = :organizer_id
             LIMIT 1",
            ['organizer_id' => $organizerId]
        );
    }

    public function allowedTournamentLevelsForOrganizer(int $organizerId): array
    {
        $statement = $this->db()->prepare(
            "SELECT
                cg.idcapgiaidau,
                cg.macapgiaidau,
                cg.tencapgiaidau,
                cg.capkhuvucphamvi,
                cg.capdoituongthamgia,
                cg.apdung_bangdau_macdinh,
                cg.mota
             FROM Bantochuc btc
             JOIN Quyencapbtc_capgiaidau q ON q.idcapbantochuc = btc.idcapbantochuc
             JOIN Capgiaidau cg ON cg.idcapgiaidau = q.idcapgiaidau
             WHERE btc.idbantochuc = :organizer_id
               AND q.duoc_tao_giai = 1
             ORDER BY cg.idcapgiaidau ASC"
        );
        $statement->execute(['organizer_id' => $organizerId]);

        return $statement->fetchAll();
    }

    public function manageableRegionsForOrganizer(int $organizerId, ?int $levelId = null): array
    {
        $bindings = ['organizer_id' => $organizerId];
        $levelFilter = '';

        if ($levelId !== null) {
            $levelFilter = 'AND cg.idcapgiaidau = :level_id';
            $bindings['level_id'] = $levelId;
        }

        $statement = $this->db()->prepare(
            "SELECT DISTINCT
                kv.idkhuvuc,
                kv.makhuvuc,
                kv.tenkhuvuc,
                kv.capkhuvuc,
                kv.idkhuvuccha,
                cg.idcapgiaidau,
                cg.macapgiaidau,
                cg.capdoituongthamgia,
                (
                    SELECT COUNT(*)
                    FROM Doibong db
                    JOIN Khuvuc kvdb ON kvdb.idkhuvuc = db.idkhuvucdaidien
                    WHERE db.trangthai = 'HOAT_DONG'
                      AND kvdb.capkhuvuc = cg.capdoituongthamgia
                      AND fn_khuvuc_la_con(db.idkhuvucdaidien, kv.idkhuvuc) = 1
                ) AS active_team_count
             FROM Bantochuc btc
             JOIN Khuvuc kv ON kv.idkhuvuc = btc.idkhuvucquanly
             JOIN Quyencapbtc_capgiaidau q ON q.idcapbantochuc = btc.idcapbantochuc AND q.duoc_tao_giai = 1
             JOIN Capgiaidau cg ON cg.idcapgiaidau = q.idcapgiaidau AND cg.capkhuvucphamvi = kv.capkhuvuc
             WHERE btc.idbantochuc = :organizer_id
               {$levelFilter}
             ORDER BY kv.tenkhuvuc ASC"
        );
        $statement->execute($bindings);

        return $statement->fetchAll();
    }

    public function activeTeamCountForScope(int $levelId, int $regionId): int
    {
        $row = $this->first(
            "SELECT COUNT(*) AS total
             FROM Doibong db
             JOIN Khuvuc kvdb ON kvdb.idkhuvuc = db.idkhuvucdaidien
             JOIN Capgiaidau cg ON cg.idcapgiaidau = :level_id
             WHERE db.trangthai = 'HOAT_DONG'
               AND kvdb.capkhuvuc = cg.capdoituongthamgia
               AND fn_khuvuc_la_con(db.idkhuvucdaidien, :region_id) = 1",
            [
                'level_id' => $levelId,
                'region_id' => $regionId,
            ]
        );

        return (int) ($row['total'] ?? 0);
    }

    public function activeTeamIdsForScope(int $levelId, int $regionId): array
    {
        $statement = $this->db()->prepare(
            "SELECT DISTINCT db.iddoibong
             FROM Doibong db
             JOIN Khuvuc kvdb ON kvdb.idkhuvuc = db.idkhuvucdaidien
             JOIN Capgiaidau cg ON cg.idcapgiaidau = :level_id
             WHERE db.trangthai = 'HOAT_DONG'
               AND kvdb.capkhuvuc = cg.capdoituongthamgia
               AND fn_khuvuc_la_con(db.idkhuvucdaidien, :region_id) = 1"
        );
        $statement->execute([
            'level_id' => $levelId,
            'region_id' => $regionId,
        ]);

        return array_map('intval', array_column($statement->fetchAll(), 'iddoibong'));
    }

    public function eligibleTeamCountForCriteria(int $levelId, int $regionId, array $conditions): int
    {
        $achievementConditions = array_values(array_filter(
            $conditions,
            static fn (array $condition): bool => in_array(
                (string) ($condition['yeu_cau_thanh_tich'] ?? ''),
                ['VO_DICH', 'A_QUAN', 'HANG_BA', 'TOP_N', 'THEO_XEP_HANG'],
                true
            )
        ));

        if ($achievementConditions === []) {
            return $this->activeTeamCountForScope($levelId, $regionId);
        }

        $first = $achievementConditions[0];
        $requirements = array_values(array_unique(array_map(
            static fn (array $condition): string => (string) ($condition['yeu_cau_thanh_tich'] ?? ''),
            $achievementConditions
        )));
        $participantLevel = (string) ($first['capdoituongthamgia'] ?? '');
        $achievementLevelId = (int) ($first['idcapgiaidau_thanh_tich_nguon'] ?? 0);
        $recentSeasons = max(1, (int) ($first['so_mua_giai_gan_nhat_duoc_tinh'] ?? 1));
        $officialOnly = (int) ($first['chi_tinh_giai_chinh_thuc'] ?? 1) === 1;
        $sameRegionOnly = (int) ($first['bat_buoc_cung_khuvuc'] ?? 1) === 1;

        if ($participantLevel === '' || $achievementLevelId <= 0) {
            return 0;
        }

        $where = [
            "db.trangthai = 'HOAT_DONG'",
            'kvdb.capkhuvuc = :participant_level',
            'fn_khuvuc_la_con(db.idkhuvucdaidien, :team_scope_region_id) = 1',
            "tt.trangthai = 'HOP_LE'",
            'tt.idcapgiaidau = :achievement_level_id',
            "(
                SELECT COUNT(DISTINCT tt2.mua_giai)
                FROM Thanhtichdoibong tt2
                JOIN Giaidau gsrc2 ON gsrc2.idgiaidau = tt2.idgiaidau
                WHERE tt2.trangthai = 'HOP_LE'
                  AND tt2.idcapgiaidau = tt.idcapgiaidau
                  AND tt2.mua_giai > tt.mua_giai
                  AND (:recent_official_only = 0 OR gsrc2.tinhchat = 'CHINH_THUC')
                  AND (:recent_same_region_only = 0 OR fn_khuvuc_la_con(tt2.idkhuvuc, :recent_scope_region_id) = 1)
            ) < :recent_seasons",
        ];
        $bindings = [
            'participant_level' => $participantLevel,
            'team_scope_region_id' => $regionId,
            'achievement_level_id' => $achievementLevelId,
            'recent_official_only' => $officialOnly ? 1 : 0,
            'recent_same_region_only' => $sameRegionOnly ? 1 : 0,
            'recent_scope_region_id' => $regionId,
            'recent_seasons' => $recentSeasons,
        ];

        if ($officialOnly) {
            $where[] = "gsrc.tinhchat = 'CHINH_THUC'";
        }

        if ($sameRegionOnly) {
            $where[] = 'fn_khuvuc_la_con(tt.idkhuvuc, :achievement_scope_region_id) = 1';
            $bindings['achievement_scope_region_id'] = $regionId;
        }

        $explicitAchievements = array_values(array_intersect($requirements, ['VO_DICH', 'A_QUAN', 'HANG_BA']));

        if ($explicitAchievements !== []) {
            $placeholders = [];
            foreach ($explicitAchievements as $index => $achievement) {
                $key = 'achievement_' . $index;
                $placeholders[] = ':' . $key;
                $bindings[$key] = $achievement;
            }
            $where[] = 'tt.danhhieu IN (' . implode(', ', $placeholders) . ')';
        } elseif (in_array('TOP_N', $requirements, true) || in_array('THEO_XEP_HANG', $requirements, true)) {
            $minimumRank = max(1, (int) ($first['hang_toi_thieu_duoc_phep'] ?? 0));
            $where[] = 'tt.hang_dat_duoc <= :minimum_rank';
            $bindings['minimum_rank'] = $minimumRank;
        } else {
            return 0;
        }

        $row = $this->first(
            "SELECT COUNT(DISTINCT db.iddoibong) AS total
             FROM Doibong db
             JOIN Khuvuc kvdb ON kvdb.idkhuvuc = db.idkhuvucdaidien
             JOIN Thanhtichdoibong tt ON tt.iddoibong = db.iddoibong
             JOIN Giaidau gsrc ON gsrc.idgiaidau = tt.idgiaidau
             WHERE " . implode(' AND ', $where),
            $bindings
        );

        return (int) ($row['total'] ?? 0);
    }

    public function eligibleTeamIdsForCriteria(int $levelId, int $regionId, array $conditions): array
    {
        $achievementConditions = array_values(array_filter(
            $conditions,
            static fn (array $condition): bool => in_array(
                (string) ($condition['yeu_cau_thanh_tich'] ?? ''),
                ['VO_DICH', 'A_QUAN', 'HANG_BA', 'TOP_N', 'THEO_XEP_HANG'],
                true
            )
        ));

        if ($achievementConditions === []) {
            return $this->activeTeamIdsForScope($levelId, $regionId);
        }

        $first = $achievementConditions[0];
        $requirements = array_values(array_unique(array_map(
            static fn (array $condition): string => (string) ($condition['yeu_cau_thanh_tich'] ?? ''),
            $achievementConditions
        )));
        $participantLevel = (string) ($first['capdoituongthamgia'] ?? '');
        $achievementLevelId = (int) ($first['idcapgiaidau_thanh_tich_nguon'] ?? 0);
        $recentSeasons = max(1, (int) ($first['so_mua_giai_gan_nhat_duoc_tinh'] ?? 1));
        $officialOnly = (int) ($first['chi_tinh_giai_chinh_thuc'] ?? 1) === 1;
        $sameRegionOnly = (int) ($first['bat_buoc_cung_khuvuc'] ?? 1) === 1;

        if ($participantLevel === '' || $achievementLevelId <= 0) {
            return [];
        }

        $where = [
            "db.trangthai = 'HOAT_DONG'",
            'kvdb.capkhuvuc = :participant_level',
            'fn_khuvuc_la_con(db.idkhuvucdaidien, :team_scope_region_id) = 1',
            "tt.trangthai = 'HOP_LE'",
            'tt.idcapgiaidau = :achievement_level_id',
            "(
                SELECT COUNT(DISTINCT tt2.mua_giai)
                FROM Thanhtichdoibong tt2
                JOIN Giaidau gsrc2 ON gsrc2.idgiaidau = tt2.idgiaidau
                WHERE tt2.trangthai = 'HOP_LE'
                  AND tt2.idcapgiaidau = tt.idcapgiaidau
                  AND tt2.mua_giai > tt.mua_giai
                  AND (:recent_official_only = 0 OR gsrc2.tinhchat = 'CHINH_THUC')
                  AND (:recent_same_region_only = 0 OR fn_khuvuc_la_con(tt2.idkhuvuc, :recent_scope_region_id) = 1)
            ) < :recent_seasons",
        ];
        $bindings = [
            'participant_level' => $participantLevel,
            'team_scope_region_id' => $regionId,
            'achievement_level_id' => $achievementLevelId,
            'recent_official_only' => $officialOnly ? 1 : 0,
            'recent_same_region_only' => $sameRegionOnly ? 1 : 0,
            'recent_scope_region_id' => $regionId,
            'recent_seasons' => $recentSeasons,
        ];

        if ($officialOnly) {
            $where[] = "gsrc.tinhchat = 'CHINH_THUC'";
        }

        if ($sameRegionOnly) {
            $where[] = 'fn_khuvuc_la_con(tt.idkhuvuc, :achievement_scope_region_id) = 1';
            $bindings['achievement_scope_region_id'] = $regionId;
        }

        $explicitAchievements = array_values(array_intersect($requirements, ['VO_DICH', 'A_QUAN', 'HANG_BA']));

        if ($explicitAchievements !== []) {
            $placeholders = [];
            foreach ($explicitAchievements as $index => $achievement) {
                $key = 'achievement_' . $index;
                $placeholders[] = ':' . $key;
                $bindings[$key] = $achievement;
            }
            $where[] = 'tt.danhhieu IN (' . implode(', ', $placeholders) . ')';
        } elseif (in_array('TOP_N', $requirements, true) || in_array('THEO_XEP_HANG', $requirements, true)) {
            $minimumRank = max(1, (int) ($first['hang_toi_thieu_duoc_phep'] ?? 0));
            $where[] = 'tt.hang_dat_duoc <= :minimum_rank';
            $bindings['minimum_rank'] = $minimumRank;
        } else {
            return [];
        }

        $statement = $this->db()->prepare(
            "SELECT DISTINCT db.iddoibong
             FROM Doibong db
             JOIN Khuvuc kvdb ON kvdb.idkhuvuc = db.idkhuvucdaidien
             JOIN Thanhtichdoibong tt ON tt.iddoibong = db.iddoibong
             JOIN Giaidau gsrc ON gsrc.idgiaidau = tt.idgiaidau
             WHERE " . implode(' AND ', $where)
        );
        $statement->execute($bindings);

        return array_map('intval', array_column($statement->fetchAll(), 'iddoibong'));
    }

    public function eligibleTeamIdsForTournament(int $tournamentId): array
    {
        $tournament = $this->findById($tournamentId);

        if ($tournament === null) {
            return [];
        }

        $ids = $this->eligibleTeamIdsForCriteria(
            (int) $tournament['idcapgiaidau'],
            (int) $tournament['idkhuvucphamvi'],
            $this->participationConditionsForTournament($tournamentId)
        );

        $statement = $this->db()->prepare(
            "SELECT DISTINCT iddoibong
             FROM doidudieukienthamgia
             WHERE idgiaidau = :tournament_id
               AND trangthai IN ('DU_DIEU_KIEN', 'DA_MOI', 'DA_DANG_KY', 'DA_DUYET')"
        );
        $statement->execute(['tournament_id' => $tournamentId]);

        $explicitIds = array_map('intval', array_column($statement->fetchAll(), 'iddoibong'));

        return array_values(array_unique(array_merge($ids, $explicitIds)));
    }

    public function teamEligibilityForTournament(int $tournamentId, int $teamId): array
    {
        $team = $this->first(
            "SELECT
                db.iddoibong,
                db.tendoibong,
                db.trangthai,
                db.idkhuvucdaidien,
                kv.tenkhuvuc AS tenkhuvucdaidien,
                kv.capkhuvuc AS capkhuvucdaidien
             FROM Doibong db
             JOIN Khuvuc kv ON kv.idkhuvuc = db.idkhuvucdaidien
             WHERE db.iddoibong = :team_id
             LIMIT 1",
            ['team_id' => $teamId]
        );

        if ($team === null) {
            return [
                'eligible' => false,
                'reason' => 'Khong tim thay doi bong.',
            ];
        }

        if ((string) $team['trangthai'] !== 'HOAT_DONG') {
            return [
                'eligible' => false,
                'reason' => 'Doi bong khong o trang thai hoat dong.',
            ];
        }

        $eligibleIds = $this->eligibleTeamIdsForTournament($tournamentId);

        if (in_array($teamId, $eligibleIds, true)) {
            return [
                'eligible' => true,
                'reason' => 'Doi bong dap ung dieu kien tham gia giai dau.',
            ];
        }

        $conditions = $this->participationConditionsForTournament($tournamentId);
        $allowException = false;
        foreach ($conditions as $condition) {
            if ((int) ($condition['cho_phep_btc_duyet_ngoai_le'] ?? 0) === 1) {
                $allowException = true;
                break;
            }
        }

        return [
            'eligible' => false,
            'reason' => $allowException
                ? 'Doi bong chua dap ung dieu kien tu dang ky. Ban to chuc co the xet ngoai le neu dieu le cho phep.'
                : 'Doi bong chua dap ung dieu kien tham gia giai dau.',
            'team_region_level' => (string) ($team['capkhuvucdaidien'] ?? ''),
            'team_region_name' => (string) ($team['tenkhuvucdaidien'] ?? ''),
        ];
    }

    public function activeCompetitionRules(): array
    {
        $statement = $this->db()->query(
            "SELECT
                idluat,
                tenluat,
                phienban,
                so_vdv_thi_dau,
                so_vdv_du_bi,
                tong_vdv_toi_da,
                kieu_tran,
                so_set_thang_tran,
                diem_set_thuong,
                diem_set_quyet_dinh,
                cach_biet_toi_thieu,
                noidung_mota
             FROM Luatthidau
             WHERE trangthai = 'HOAT_DONG'
             ORDER BY idluat ASC"
        );

        return $statement->fetchAll();
    }

    public function tournamentLevels(): array
    {
        $statement = $this->db()->query(
            "SELECT
                idcapgiaidau,
                macapgiaidau,
                tencapgiaidau,
                capkhuvucphamvi,
                capdoituongthamgia,
                apdung_bangdau_macdinh,
                mota
             FROM Capgiaidau
             ORDER BY idcapgiaidau ASC"
        );

        return $statement->fetchAll();
    }

    public function createTournament(
        array $tournament,
        array $configuration,
        int $actorAccountId,
        ?string $ipAddress,
        string $logNote
    ): int {
        $db = $this->db();

        try {
            $db->beginTransaction();

            $statement = $db->prepare(
                "INSERT INTO Giaidau
                    (tengiaidau, mota, idcapgiaidau, idkhuvucphamvi, idbantochuc, idluat, thoigianbatdau, thoigianketthuc, quymo, hinhanh, tinhchat, trangthai, trangthaidangky, trangthaithietlap, ghichu_diadiem)
                 VALUES
                    (:tengiaidau, :mota, :idcapgiaidau, :idkhuvucphamvi, :idbantochuc, :idluat, :thoigianbatdau, :thoigianketthuc, :quymo, :hinhanh, :tinhchat, 'NHAP', 'CHUA_MO', 'DANG_THIET_LAP', :ghichu_diadiem)"
            );

            $statement->execute([
                'tengiaidau' => $tournament['tengiaidau'],
                'mota' => $tournament['mota'],
                'idcapgiaidau' => $tournament['idcapgiaidau'],
                'idkhuvucphamvi' => $tournament['idkhuvucphamvi'],
                'idbantochuc' => $tournament['idbantochuc'],
                'idluat' => $tournament['idluat'],
                'thoigianbatdau' => $tournament['thoigianbatdau'],
                'thoigianketthuc' => $tournament['thoigianketthuc'],
                'quymo' => $tournament['quymo'],
                'hinhanh' => $tournament['hinhanh'],
                'tinhchat' => $tournament['tinhchat'],
                'ghichu_diadiem' => $tournament['ghichu_diadiem'],
            ]);

            $tournamentId = (int) $db->lastInsertId();

            $this->insertRegulations($tournamentId, $configuration['dieule']);
            $this->insertCompetitionFormat($tournamentId, $configuration['thethuc']);
            $this->insertDefaultRounds($tournamentId, $configuration['thethuc'], (int) $tournament['quymo']);
            $teamSelectionRuleId = $this->insertTeamSelectionRule($tournamentId, $configuration['quytac']);
            $this->insertParticipationConditions($tournamentId, $teamSelectionRuleId, $configuration['dieukien']);
            $this->recordStatusHistory('GIAI_DAU', $tournamentId, null, 'NHAP', 'Tao giai dau o trang thai nhap', $actorAccountId);
            $this->recordSystemLog($actorAccountId, 'Tao giai dau', 'Giaidau', $tournamentId, $ipAddress, $logNote);

            $db->commit();

            return $tournamentId;
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    public function updateTournament(
        int $tournamentId,
        array $tournament,
        ?array $configuration,
        int $actorAccountId,
        ?string $ipAddress,
        string $logNote
    ): void {
        $db = $this->db();

        try {
            $db->beginTransaction();

            $this->updateTournamentFields($tournamentId, $tournament);

            if ($configuration !== null) {
                if (isset($configuration['dieule'])) {
                    $this->replaceRegulations($tournamentId, $configuration['dieule']);
                }

                if (isset($configuration['thethuc'])) {
                    $this->replaceCompetitionFormat($tournamentId, $configuration['thethuc']);
                }

                if (isset($configuration['quytac'])) {
                    $this->replaceTeamSelectionRule($tournamentId, $configuration['quytac'], $configuration['dieukien']);
                }
            }

            $this->recordSystemLog($actorAccountId, 'Cap nhat giai dau', 'Giaidau', $tournamentId, $ipAddress, $logNote);

            $db->commit();
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    public function deleteTournament(
        int $tournamentId,
        int $actorAccountId,
        ?string $ipAddress,
        string $logNote
    ): void {
        $db = $this->db();

        try {
            $db->beginTransaction();

            $this->recordStatusHistory('GIAI_DAU', $tournamentId, 'CHUA_CONG_BO', 'DA_HUY', 'Xoa giai dau chua cong bo', $actorAccountId);
            $this->recordSystemLog($actorAccountId, 'Xoa giai dau', 'Giaidau', $tournamentId, $ipAddress, $logNote);

            $statement = $db->prepare(
                "DELETE FROM Giaidau
                 WHERE idgiaidau = :tournament_id
                   AND trangthai IN ('NHAP', 'CHUA_CONG_BO')"
            );

            $statement->execute(['tournament_id' => $tournamentId]);

            if ($statement->rowCount() !== 1) {
                throw new \RuntimeException('TOURNAMENT_NOT_DELETED');
            }

            $db->commit();
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    public function publishTournament(
        int $tournamentId,
        int $actorAccountId,
        ?string $ipAddress,
        string $logNote
    ): void {
        $db = $this->db();

        try {
            $db->beginTransaction();

            $statement = $db->prepare(
                "UPDATE Giaidau
                 SET trangthai = 'DA_CONG_BO',
                     ngaycapnhat = CURRENT_TIMESTAMP
                 WHERE idgiaidau = :tournament_id
                   AND trangthai IN ('NHAP', 'CHUA_CONG_BO')"
            );

            $statement->execute(['tournament_id' => $tournamentId]);

            if ($statement->rowCount() !== 1) {
                throw new \RuntimeException('TOURNAMENT_NOT_PUBLISHED');
            }

            $this->recordStatusHistory('GIAI_DAU', $tournamentId, null, 'DA_CONG_BO', 'Cong bo giai dau', $actorAccountId);
            $this->recordSystemLog($actorAccountId, 'Cong bo giai dau', 'Giaidau', $tournamentId, $ipAddress, $logNote);

            $db->commit();
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    public function updateRegistrationWindow(
        int $tournamentId,
        string $oldStatus,
        string $newStatus,
        int $actorAccountId,
        ?string $ipAddress,
        string $logNote
    ): void {
        $db = $this->db();
        $action = $newStatus === 'DANG_MO' ? 'Mo dang ky giai dau' : 'Dong dang ky giai dau';

        try {
            $db->beginTransaction();

            $statement = $db->prepare(
                "UPDATE Giaidau
                 SET trangthaidangky = :new_status,
                     ngaycapnhat = CURRENT_TIMESTAMP
                 WHERE idgiaidau = :tournament_id
                   AND trangthai = 'DA_CONG_BO'
                   AND trangthaidangky = :old_status"
            );

            $statement->execute([
                'new_status' => $newStatus,
                'tournament_id' => $tournamentId,
                'old_status' => $oldStatus,
            ]);

            if ($statement->rowCount() !== 1) {
                throw new \RuntimeException('REGISTRATION_WINDOW_NOT_UPDATED');
            }

            $this->recordStatusHistory('GIAI_DAU', $tournamentId, $oldStatus, $newStatus, $action, $actorAccountId);

            if ($newStatus === 'DANG_MO') {
                $this->notifyEligibleTeamsRegistrationOpen($tournamentId);
            }

            $this->recordSystemLog($actorAccountId, $action, 'Giaidau', $tournamentId, $ipAddress, $logNote);

            $db->commit();
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    private function notifyEligibleTeamsRegistrationOpen(int $tournamentId): void
    {
        $eligibleTeamIds = $this->eligibleTeamIdsForTournament($tournamentId);

        if ($eligibleTeamIds === []) {
            return;
        }

        $bindings = ['tournament_id' => $tournamentId];
        $placeholders = [];
        foreach ($eligibleTeamIds as $index => $teamId) {
            $key = 'team_id_' . $index;
            $placeholders[] = ':' . $key;
            $bindings[$key] = $teamId;
        }

        $statement = $this->db()->prepare(
            "INSERT INTO Thongbao (idnguoinhan, tieude, noidung, loai, trangthai)
             SELECT
                nd.idtaikhoan,
                CONCAT('Mời đăng ký giải đấu: ', gd.tengiaidau),
                CONCAT('Giải đấu ', gd.tengiaidau, ' đã mở đăng ký. Đội ', db.tendoibong, ' có thể gửi hồ sơ tham gia.'),
                'HE_THONG',
                'CHUA_DOC'
             FROM Giaidau gd
             JOIN Doibong db ON db.trangthai = 'HOAT_DONG'
             JOIN Huanluyenvien hlv ON hlv.idhuanluyenvien = db.idhuanluyenvien
             JOIN Nguoidung nd ON nd.idnguoidung = hlv.idnguoidung
             WHERE gd.idgiaidau = :tournament_id
               AND db.iddoibong IN (" . implode(', ', $placeholders) . ")
               AND hlv.trangthai = 'DA_XAC_NHAN'
               AND NOT EXISTS (
                    SELECT 1
                    FROM Dangkygiaidau dk
                    WHERE dk.idgiaidau = gd.idgiaidau
                      AND dk.iddoibong = db.iddoibong
                      AND dk.trangthai <> 'DA_HUY'
               )
               AND NOT EXISTS (
                    SELECT 1
                    FROM Thongbao tb
                    WHERE tb.idnguoinhan = nd.idtaikhoan
                      AND tb.tieude = CONCAT('Mời đăng ký giải đấu: ', gd.tengiaidau)
               )"
        );

        $statement->execute($bindings);
    }

    public function registrationsForTournament(int $tournamentId, array $filters = []): array
    {
        $where = ['dk.idgiaidau = :tournament_id'];
        $bindings = ['tournament_id' => $tournamentId];

        if (($filters['status'] ?? '') !== '') {
            $where[] = 'dk.trangthai = :status';
            $bindings['status'] = $filters['status'];
        }

        if (($filters['q'] ?? '') !== '') {
            $where[] = "(db.tendoibong LIKE :keyword
                OR db.diaphuong LIKE :keyword
                OR CONCAT(COALESCE(nd.hodem, ''), ' ', COALESCE(nd.ten, '')) LIKE :keyword)";
            $bindings['keyword'] = '%' . $filters['q'] . '%';
        }

        $statement = $this->db()->prepare(
            "SELECT
                dk.iddangky,
                dk.idgiaidau,
                dk.iddoibong,
                dk.idhuanluyenvien,
                dk.ngaydangky,
                dk.trangthai,
                dk.lydotuchoi,
                db.tendoibong,
                db.logo AS doibong_logo,
                db.diaphuong AS doibong_diaphuong,
                db.trangthai AS doibong_trangthai,
                hlv.bangcap AS huanluyenvien_bangcap,
                hlv.kinhnghiem AS huanluyenvien_kinhnghiem,
                hlv.trangthai AS huanluyenvien_trangthai,
                nd.idnguoidung AS huanluyenvien_idnguoidung,
                TRIM(CONCAT(COALESCE(nd.hodem, ''), ' ', COALESCE(nd.ten, ''))) AS huanluyenvien_hoten,
                tk.username AS huanluyenvien_username,
                tk.email AS huanluyenvien_email
             FROM Dangkygiaidau dk
             JOIN Doibong db ON db.iddoibong = dk.iddoibong
             JOIN Huanluyenvien hlv ON hlv.idhuanluyenvien = dk.idhuanluyenvien
             JOIN Nguoidung nd ON nd.idnguoidung = hlv.idnguoidung
             JOIN Taikhoan tk ON tk.idtaikhoan = nd.idtaikhoan
             WHERE " . implode(' AND ', $where) . "
             ORDER BY dk.ngaydangky DESC, dk.iddangky DESC"
        );

        $statement->execute($bindings);

        return $statement->fetchAll();
    }

    public function registrationsForCoach(int $coachId, array $filters = []): array
    {
        $where = ['dk.idhuanluyenvien = :coach_id'];
        $bindings = ['coach_id' => $coachId];

        if (($filters['registration_id'] ?? '') !== '') {
            $where[] = 'dk.iddangky = :registration_id';
            $bindings['registration_id'] = (int) $filters['registration_id'];
        }

        if (($filters['status'] ?? '') !== '') {
            $where[] = 'dk.trangthai = :status';
            $bindings['status'] = $filters['status'];
        }

        if (($filters['tournament_id'] ?? '') !== '') {
            $where[] = 'dk.idgiaidau = :tournament_id';
            $bindings['tournament_id'] = (int) $filters['tournament_id'];
        }

        if (($filters['team_id'] ?? '') !== '') {
            $where[] = 'dk.iddoibong = :team_id';
            $bindings['team_id'] = (int) $filters['team_id'];
        }

        if (($filters['q'] ?? '') !== '') {
            $where[] = "CONCAT_WS(' ', gd.tengiaidau, gd.ghichu_diadiem, db.tendoibong, db.diaphuong, dk.lydotuchoi) LIKE :keyword";
            $bindings['keyword'] = '%' . $filters['q'] . '%';
        }

        if (($filters['from'] ?? '') !== '') {
            $where[] = 'DATE(dk.ngaydangky) >= :from_date';
            $bindings['from_date'] = $filters['from'];
        }

        if (($filters['to'] ?? '') !== '') {
            $where[] = 'DATE(dk.ngaydangky) <= :to_date';
            $bindings['to_date'] = $filters['to'];
        }

        $statement = $this->db()->prepare(
            "SELECT
                dk.iddangky,
                dk.idgiaidau,
                dk.iddoibong,
                dk.idhuanluyenvien,
                dk.ngaydangky,
                dk.trangthai,
                dk.lydotuchoi,
                gd.tengiaidau,
                gd.mota AS giaidau_mota,
                gd.thoigianbatdau,
                gd.thoigianketthuc,
                gd.ghichu_diadiem AS diadiem,
                COALESCE(dl.so_doi_toi_da, gd.quymo) AS quymo,
                gd.trangthai AS trangthaigiaidau,
                gd.trangthaidangky AS trangthaidangkygiaidau,
                gd.idbantochuc,
                db.tendoibong,
                db.logo AS doibong_logo,
                db.diaphuong AS doibong_diaphuong,
                db.trangthai AS doibong_trangthai,
                (
                    SELECT yc.idyeucau
                    FROM Yeucauxacnhan yc
                    WHERE yc.loainguoigui = 'HUAN_LUYEN_VIEN'
                      AND yc.idnguoigui = dk.idhuanluyenvien
                      AND yc.loainguoinhan = 'BAN_TO_CHUC'
                      AND yc.idnguoinhan = gd.idbantochuc
                      AND yc.loaixacnhan = 'XAC_NHAN_DANG_KY_GIAI'
                      AND yc.noidung LIKE CONCAT('Dang ky giai dau #', dk.idgiaidau, ', doi #', dk.iddoibong, '.%')
                    ORDER BY yc.idyeucau DESC
                    LIMIT 1
                ) AS yeucau_id,
                (
                    SELECT yc.trangthai
                    FROM Yeucauxacnhan yc
                    WHERE yc.loainguoigui = 'HUAN_LUYEN_VIEN'
                      AND yc.idnguoigui = dk.idhuanluyenvien
                      AND yc.loainguoinhan = 'BAN_TO_CHUC'
                      AND yc.idnguoinhan = gd.idbantochuc
                      AND yc.loaixacnhan = 'XAC_NHAN_DANG_KY_GIAI'
                      AND yc.noidung LIKE CONCAT('Dang ky giai dau #', dk.idgiaidau, ', doi #', dk.iddoibong, '.%')
                    ORDER BY yc.idyeucau DESC
                    LIMIT 1
                ) AS yeucau_trangthai,
                (
                    SELECT yc.noidung
                    FROM Yeucauxacnhan yc
                    WHERE yc.loainguoigui = 'HUAN_LUYEN_VIEN'
                      AND yc.idnguoigui = dk.idhuanluyenvien
                      AND yc.loainguoinhan = 'BAN_TO_CHUC'
                      AND yc.idnguoinhan = gd.idbantochuc
                      AND yc.loaixacnhan = 'XAC_NHAN_DANG_KY_GIAI'
                      AND yc.noidung LIKE CONCAT('Dang ky giai dau #', dk.idgiaidau, ', doi #', dk.iddoibong, '.%')
                    ORDER BY yc.idyeucau DESC
                    LIMIT 1
                ) AS yeucau_noidung,
                (
                    SELECT yc.ngaygui
                    FROM Yeucauxacnhan yc
                    WHERE yc.loainguoigui = 'HUAN_LUYEN_VIEN'
                      AND yc.idnguoigui = dk.idhuanluyenvien
                      AND yc.loainguoinhan = 'BAN_TO_CHUC'
                      AND yc.idnguoinhan = gd.idbantochuc
                      AND yc.loaixacnhan = 'XAC_NHAN_DANG_KY_GIAI'
                      AND yc.noidung LIKE CONCAT('Dang ky giai dau #', dk.idgiaidau, ', doi #', dk.iddoibong, '.%')
                    ORDER BY yc.idyeucau DESC
                    LIMIT 1
                ) AS yeucau_ngaygui,
                (
                    SELECT yc.ngayxuly
                    FROM Yeucauxacnhan yc
                    WHERE yc.loainguoigui = 'HUAN_LUYEN_VIEN'
                      AND yc.idnguoigui = dk.idhuanluyenvien
                      AND yc.loainguoinhan = 'BAN_TO_CHUC'
                      AND yc.idnguoinhan = gd.idbantochuc
                      AND yc.loaixacnhan = 'XAC_NHAN_DANG_KY_GIAI'
                      AND yc.noidung LIKE CONCAT('Dang ky giai dau #', dk.idgiaidau, ', doi #', dk.iddoibong, '.%')
                    ORDER BY yc.idyeucau DESC
                    LIMIT 1
                ) AS yeucau_ngayxuly,
                (
                    SELECT yc.ghichu
                    FROM Yeucauxacnhan yc
                    WHERE yc.loainguoigui = 'HUAN_LUYEN_VIEN'
                      AND yc.idnguoigui = dk.idhuanluyenvien
                      AND yc.loainguoinhan = 'BAN_TO_CHUC'
                      AND yc.idnguoinhan = gd.idbantochuc
                      AND yc.loaixacnhan = 'XAC_NHAN_DANG_KY_GIAI'
                      AND yc.noidung LIKE CONCAT('Dang ky giai dau #', dk.idgiaidau, ', doi #', dk.iddoibong, '.%')
                    ORDER BY yc.idyeucau DESC
                    LIMIT 1
                ) AS yeucau_ghichu
             FROM Dangkygiaidau dk
             JOIN Giaidau gd ON gd.idgiaidau = dk.idgiaidau
             LEFT JOIN Dieulegiaidau dl ON dl.idgiaidau = gd.idgiaidau
             JOIN Doibong db ON db.iddoibong = dk.iddoibong
             WHERE " . implode(' AND ', $where) . "
             ORDER BY dk.ngaydangky DESC, dk.iddangky DESC"
        );

        $statement->execute($bindings);

        return $statement->fetchAll();
    }

    public function findRegistrationForCoach(int $coachId, int $registrationId): ?array
    {
        $rows = $this->registrationsForCoach($coachId, [
            'registration_id' => (string) $registrationId,
        ]);

        return $rows[0] ?? null;
    }

    public function registrationExists(int $tournamentId, int $teamId): bool
    {
        return $this->first(
            "SELECT 1
             FROM Dangkygiaidau
             WHERE idgiaidau = :tournament_id
               AND iddoibong = :team_id
             LIMIT 1",
            [
                'tournament_id' => $tournamentId,
                'team_id' => $teamId,
            ]
        ) !== null;
    }

    public function registerTeamForTournament(
        int $tournamentId,
        int $teamId,
        int $coachId,
        int $organizerId,
        string $content,
        int $actorAccountId,
        ?string $ipAddress,
        string $logNote
    ): array {
        $db = $this->db();
        $requestContent = $this->registrationRequestMarker($tournamentId, $teamId) . ' ' . $content;

        if (strlen($requestContent) > 1000) {
            $requestContent = substr($requestContent, 0, 997) . '...';
        }

        try {
            $db->beginTransaction();

            $statement = $db->prepare(
                "INSERT INTO Dangkygiaidau (idgiaidau, iddoibong, idhuanluyenvien, trangthai)
                 VALUES (:tournament_id, :team_id, :coach_id, 'CHO_DUYET')"
            );
            $statement->execute([
                'tournament_id' => $tournamentId,
                'team_id' => $teamId,
                'coach_id' => $coachId,
            ]);

            $registrationId = (int) $db->lastInsertId();

            $statement = $db->prepare(
                "INSERT INTO Yeucauxacnhan
                    (loainguoigui, idnguoigui, loainguoinhan, idnguoinhan, loaixacnhan, noidung, trangthai)
                 VALUES
                    ('HUAN_LUYEN_VIEN', :coach_id, 'BAN_TO_CHUC', :organizer_id, 'XAC_NHAN_DANG_KY_GIAI', :content, 'CHO_DUYET')"
            );
            $statement->execute([
                'coach_id' => $coachId,
                'organizer_id' => $organizerId,
                'content' => $requestContent,
            ]);

            $requestId = (int) $db->lastInsertId();

            $this->recordStatusHistory('DANG_KY_GIAI', $registrationId, null, 'CHO_DUYET', 'HLV dang ky giai dau', $actorAccountId);
            $this->recordStatusHistory('YEU_CAU_XAC_NHAN', $requestId, null, 'CHO_DUYET', 'Gui yeu cau xac nhan dang ky giai dau', $actorAccountId);
            $this->recordSystemLog($actorAccountId, 'Dang ky giai dau', 'Dangkygiaidau', $registrationId, $ipAddress, $logNote);
            $this->recordSystemLog($actorAccountId, 'Gui yeu cau xac nhan dang ky giai dau', 'Yeucauxacnhan', $requestId, $ipAddress, $logNote);

            $db->commit();

            return [
                'registration_id' => $registrationId,
                'request_id' => $requestId,
                'registration_status' => 'CHO_DUYET',
                'request_status' => 'CHO_DUYET',
            ];
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    public function cancelRegistrationForCoach(
        int $registrationId,
        int $coachId,
        string $reason,
        int $actorAccountId,
        ?string $ipAddress,
        string $logNote
    ): void {
        $db = $this->db();

        try {
            $db->beginTransaction();

            $request = $this->findPendingTournamentRegistrationRequest($registrationId);

            $statement = $db->prepare(
                "UPDATE Dangkygiaidau
                 SET trangthai = 'DA_HUY',
                     lydotuchoi = :reason
                 WHERE iddangky = :registration_id
                   AND idhuanluyenvien = :coach_id
                   AND trangthai = 'CHO_DUYET'"
            );
            $statement->execute([
                'reason' => $reason,
                'registration_id' => $registrationId,
                'coach_id' => $coachId,
            ]);

            if ($statement->rowCount() !== 1) {
                throw new \RuntimeException('REGISTRATION_NOT_CANCELLED');
            }

            $this->recordStatusHistory('DANG_KY_GIAI', $registrationId, 'CHO_DUYET', 'DA_HUY', $reason, $actorAccountId);

            if ($request !== null) {
                $statement = $db->prepare(
                    "UPDATE Yeucauxacnhan
                     SET trangthai = 'DA_HUY',
                         ngayxuly = CURRENT_TIMESTAMP,
                         ghichu = :reason
                     WHERE idyeucau = :request_id
                       AND trangthai = 'CHO_DUYET'"
                );
                $statement->execute([
                    'reason' => $reason,
                    'request_id' => (int) $request['idyeucau'],
                ]);

                if ($statement->rowCount() === 1) {
                    $this->recordStatusHistory('YEU_CAU_XAC_NHAN', (int) $request['idyeucau'], 'CHO_DUYET', 'DA_HUY', $reason, $actorAccountId);
                }
            }

            $this->recordSystemLog($actorAccountId, 'Huy dang ky giai dau', 'Dangkygiaidau', $registrationId, $ipAddress, $logNote);

            $db->commit();
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    public function registrationStatsForTournament(int $tournamentId): array
    {
        $statement = $this->db()->prepare(
            "SELECT trangthai, COUNT(*) AS total
             FROM Dangkygiaidau
             WHERE idgiaidau = :tournament_id
             GROUP BY trangthai"
        );

        $statement->execute(['tournament_id' => $tournamentId]);

        $stats = [
            'CHO_DUYET' => 0,
            'DA_DUYET' => 0,
            'TU_CHOI' => 0,
            'DA_HUY' => 0,
        ];

        foreach ($statement->fetchAll() as $row) {
            $stats[(string) $row['trangthai']] = (int) $row['total'];
        }

        return $stats;
    }

    public function findRegistration(int $tournamentId, int $registrationId): ?array
    {
        return $this->first(
            "SELECT
                dk.iddangky,
                dk.idgiaidau,
                dk.iddoibong,
                dk.idhuanluyenvien,
                dk.ngaydangky,
                dk.trangthai,
                dk.lydotuchoi,
                db.tendoibong,
                db.logo AS doibong_logo,
                db.diaphuong AS doibong_diaphuong,
                db.trangthai AS doibong_trangthai,
                hlv.bangcap AS huanluyenvien_bangcap,
                hlv.kinhnghiem AS huanluyenvien_kinhnghiem,
                hlv.trangthai AS huanluyenvien_trangthai,
                nd.idnguoidung AS huanluyenvien_idnguoidung,
                TRIM(CONCAT(COALESCE(nd.hodem, ''), ' ', COALESCE(nd.ten, ''))) AS huanluyenvien_hoten,
                tk.username AS huanluyenvien_username,
                tk.email AS huanluyenvien_email
             FROM Dangkygiaidau dk
             JOIN Doibong db ON db.iddoibong = dk.iddoibong
             JOIN Huanluyenvien hlv ON hlv.idhuanluyenvien = dk.idhuanluyenvien
             JOIN Nguoidung nd ON nd.idnguoidung = hlv.idnguoidung
             JOIN Taikhoan tk ON tk.idtaikhoan = nd.idtaikhoan
             WHERE dk.idgiaidau = :tournament_id
               AND dk.iddangky = :registration_id
             LIMIT 1",
            [
                'tournament_id' => $tournamentId,
                'registration_id' => $registrationId,
            ]
        );
    }

    public function approvedRegistrationCount(int $tournamentId): int
    {
        $row = $this->first(
            "SELECT COUNT(*) AS total
             FROM Dangkygiaidau
             WHERE idgiaidau = :tournament_id
               AND trangthai = 'DA_DUYET'",
            ['tournament_id' => $tournamentId]
        );

        return (int) ($row['total'] ?? 0);
    }

    public function registrationLimitForTournament(int $tournamentId): ?int
    {
        $row = $this->first(
            "SELECT COALESCE(dl.so_doi_toi_da, gd.quymo) AS registration_limit
             FROM Giaidau gd
             LEFT JOIN Dieulegiaidau dl ON dl.idgiaidau = gd.idgiaidau
             WHERE gd.idgiaidau = :tournament_id
             LIMIT 1",
            ['tournament_id' => $tournamentId]
        );

        if ($row === null || $row['registration_limit'] === null) {
            return null;
        }

        return (int) $row['registration_limit'];
    }

    public function decideRegistration(
        int $tournamentId,
        int $registrationId,
        string $oldStatus,
        string $newStatus,
        ?string $rejectionReason,
        int $actorAccountId,
        ?string $ipAddress,
        string $logNote
    ): void {
        $db = $this->db();
        $action = $newStatus === 'DA_DUYET' ? 'Duyet dang ky doi bong' : 'Tu choi dang ky doi bong';
        $requestNote = $rejectionReason ?: $action;

        try {
            $db->beginTransaction();

            $request = $this->findPendingTournamentRegistrationRequest($registrationId);

            $statement = $db->prepare(
                "UPDATE Dangkygiaidau
                 SET trangthai = :new_status,
                     lydotuchoi = :rejection_reason
                 WHERE iddangky = :registration_id
                   AND idgiaidau = :tournament_id
                   AND trangthai = :old_status"
            );

            $statement->execute([
                'new_status' => $newStatus,
                'rejection_reason' => $rejectionReason,
                'registration_id' => $registrationId,
                'tournament_id' => $tournamentId,
                'old_status' => $oldStatus,
            ]);

            if ($statement->rowCount() !== 1) {
                throw new \RuntimeException('REGISTRATION_NOT_DECIDED');
            }

            $this->recordStatusHistory('DANG_KY_GIAI', $registrationId, $oldStatus, $newStatus, $action, $actorAccountId);

            if ($request !== null) {
                $statement = $db->prepare(
                    "UPDATE Yeucauxacnhan
                     SET trangthai = :new_status,
                         ngayxuly = CURRENT_TIMESTAMP,
                         ghichu = :note
                     WHERE idyeucau = :request_id
                       AND trangthai = 'CHO_DUYET'"
                );
                $statement->execute([
                    'new_status' => $newStatus,
                    'note' => $requestNote,
                    'request_id' => (int) $request['idyeucau'],
                ]);

                if ($statement->rowCount() === 1) {
                    $this->recordStatusHistory('YEU_CAU_XAC_NHAN', (int) $request['idyeucau'], 'CHO_DUYET', $newStatus, $requestNote, $actorAccountId);
                }
            }

            $this->recordSystemLog($actorAccountId, $action, 'Dangkygiaidau', $registrationId, $ipAddress, $logNote);

            $db->commit();
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    public function findById(int $tournamentId): ?array
    {
        return $this->first(
            "SELECT
                gd.idgiaidau,
                gd.tengiaidau,
                gd.mota,
                gd.idcapgiaidau,
                cg.macapgiaidau,
                cg.tencapgiaidau,
                cg.capkhuvucphamvi,
                cg.capdoituongthamgia,
                gd.idkhuvucphamvi,
                kv.makhuvuc AS makhuvuc_phamvi,
                kv.tenkhuvuc AS tenkhuvuc_phamvi,
                kv.capkhuvuc AS capkhuvuc_phamvi,
                gd.idluat,
                lt.tenluat,
                lt.kieu_tran,
                gd.thoigianbatdau,
                gd.thoigianketthuc,
                gd.quymo,
                gd.hinhanh,
                gd.tinhchat,
                gd.trangthai,
                gd.trangthaidangky,
                gd.trangthaithietlap,
                gd.ghichu_diadiem,
                gd.idbantochuc,
                gd.ngaytao,
                gd.ngaycapnhat,
                btc.donvi AS bantochuc_donvi,
                btc.chucvu AS bantochuc_chucvu
             FROM Giaidau gd
             JOIN Bantochuc btc ON btc.idbantochuc = gd.idbantochuc
             JOIN Capgiaidau cg ON cg.idcapgiaidau = gd.idcapgiaidau
             JOIN Khuvuc kv ON kv.idkhuvuc = gd.idkhuvucphamvi
             JOIN Luatthidau lt ON lt.idluat = gd.idluat
             LEFT JOIN Dieulegiaidau dl ON dl.idgiaidau = gd.idgiaidau
             WHERE gd.idgiaidau = :tournament_id
             LIMIT 1",
            ['tournament_id' => $tournamentId]
        );
    }

    public function regulationForTournament(int $tournamentId): ?array
    {
        return $this->first(
            "SELECT
                iddieule,
                idgiaidau,
                tieude,
                noidung,
                filedinhkem,
                so_doi_toi_thieu,
                so_doi_toi_da,
                so_vdv_toi_thieu_moi_doi,
                so_vdv_toi_da_moi_doi,
                thoi_gian_mo_dang_ky,
                thoi_gian_dong_dang_ky,
                cho_phep_dang_ky_tu_do,
                yeu_cau_duyet_dang_ky,
                quy_dinh_bo_cuoc,
                quy_dinh_khieu_nai,
                ngaytao
             FROM Dieulegiaidau
             WHERE idgiaidau = :tournament_id
             LIMIT 1",
            ['tournament_id' => $tournamentId]
        );
    }

    public function competitionFormatForTournament(int $tournamentId): ?array
    {
        return $this->first(
            "SELECT
                idthethuc,
                idgiaidau,
                tenthethuc,
                tong_so_vong,
                co_vong_diem,
                co_vong_loai,
                co_tranh_hang_ba,
                cach_xep_mac_dinh,
                seed_source_mac_dinh,
                mota,
                trangthai
             FROM Thethucgiaidau
             WHERE idgiaidau = :tournament_id
             LIMIT 1",
            ['tournament_id' => $tournamentId]
        );
    }

    public function teamSelectionRuleForTournament(int $tournamentId): ?array
    {
        return $this->first(
            "SELECT
                idquytac,
                idgiaidau,
                chedochondoi,
                capdoituongthamgia,
                yeu_cau_thanh_tich,
                idcapgiaidau_thanh_tich_nguon,
                hang_toi_thieu_duoc_phep,
                so_mua_giai_gan_nhat_duoc_tinh,
                cho_phep_btc_duyet_ngoai_le,
                soluongdoitoida,
                mota,
                trangthai
             FROM Quytacchondoi
             WHERE idgiaidau = :tournament_id
               AND trangthai = 'HOAT_DONG'
             ORDER BY idquytac DESC
             LIMIT 1",
            ['tournament_id' => $tournamentId]
        );
    }

    public function participationConditionsForTournament(int $tournamentId): array
    {
        $statement = $this->db()->prepare(
            "SELECT
                dk.iddieukienthamgia,
                dk.idgiaidau,
                dk.idquytac,
                dk.ten_dieukien,
                dk.capdoituongthamgia,
                dk.yeu_cau_thanh_tich,
                dk.idcapgiaidau_thanh_tich_nguon,
                cg.macapgiaidau AS macapgiaidau_thanh_tich_nguon,
                cg.tencapgiaidau AS tencapgiaidau_thanh_tich_nguon,
                dk.hang_toi_thieu_duoc_phep,
                dk.so_mua_giai_gan_nhat_duoc_tinh,
                dk.chi_tinh_giai_chinh_thuc,
                dk.bat_buoc_cung_khuvuc,
                dk.cho_phep_btc_duyet_ngoai_le,
                dk.mota,
                dk.trangthai
             FROM Dieukienthamgiagiai dk
             LEFT JOIN Capgiaidau cg ON cg.idcapgiaidau = dk.idcapgiaidau_thanh_tich_nguon
             WHERE dk.idgiaidau = :tournament_id
               AND dk.trangthai = 'HOAT_DONG'
             ORDER BY dk.iddieukienthamgia ASC"
        );
        $statement->execute(['tournament_id' => $tournamentId]);

        return $statement->fetchAll();
    }

    private function insertRegulations(int $tournamentId, array $regulation): void
    {
        $statement = $this->db()->prepare(
            "INSERT INTO Dieulegiaidau
                (idgiaidau, tieude, noidung, filedinhkem, so_doi_toi_thieu, so_doi_toi_da, so_vdv_toi_thieu_moi_doi, so_vdv_toi_da_moi_doi, thoi_gian_mo_dang_ky, thoi_gian_dong_dang_ky, cho_phep_dang_ky_tu_do, yeu_cau_duyet_dang_ky, quy_dinh_bo_cuoc, quy_dinh_khieu_nai)
             VALUES
                (:tournament_id, :tieude, :noidung, :filedinhkem, :so_doi_toi_thieu, :so_doi_toi_da, :so_vdv_toi_thieu_moi_doi, :so_vdv_toi_da_moi_doi, :thoi_gian_mo_dang_ky, :thoi_gian_dong_dang_ky, :cho_phep_dang_ky_tu_do, :yeu_cau_duyet_dang_ky, :quy_dinh_bo_cuoc, :quy_dinh_khieu_nai)"
        );

        $statement->execute([
            'tournament_id' => $tournamentId,
            'tieude' => $regulation['tieude'],
            'noidung' => $regulation['noidung'],
            'filedinhkem' => $regulation['filedinhkem'],
            'so_doi_toi_thieu' => $regulation['so_doi_toi_thieu'],
            'so_doi_toi_da' => $regulation['so_doi_toi_da'],
            'so_vdv_toi_thieu_moi_doi' => $regulation['so_vdv_toi_thieu_moi_doi'],
            'so_vdv_toi_da_moi_doi' => $regulation['so_vdv_toi_da_moi_doi'],
            'thoi_gian_mo_dang_ky' => $regulation['thoi_gian_mo_dang_ky'],
            'thoi_gian_dong_dang_ky' => $regulation['thoi_gian_dong_dang_ky'],
            'cho_phep_dang_ky_tu_do' => $regulation['cho_phep_dang_ky_tu_do'],
            'yeu_cau_duyet_dang_ky' => $regulation['yeu_cau_duyet_dang_ky'],
            'quy_dinh_bo_cuoc' => $regulation['quy_dinh_bo_cuoc'],
            'quy_dinh_khieu_nai' => $regulation['quy_dinh_khieu_nai'],
        ]);
    }

    private function insertCompetitionFormat(int $tournamentId, array $format): void
    {
        $statement = $this->db()->prepare(
            "INSERT INTO Thethucgiaidau
                (idgiaidau, tenthethuc, tong_so_vong, co_vong_diem, co_vong_loai, co_tranh_hang_ba, cach_xep_mac_dinh, seed_source_mac_dinh, mota, trangthai)
             VALUES
                (:tournament_id, :tenthethuc, :tong_so_vong, :co_vong_diem, :co_vong_loai, :co_tranh_hang_ba, :cach_xep_mac_dinh, :seed_source_mac_dinh, :mota, :trangthai)"
        );

        $statement->execute([
            'tournament_id' => $tournamentId,
            'tenthethuc' => $format['tenthethuc'],
            'tong_so_vong' => $format['tong_so_vong'],
            'co_vong_diem' => $format['co_vong_diem'],
            'co_vong_loai' => $format['co_vong_loai'],
            'co_tranh_hang_ba' => $format['co_tranh_hang_ba'],
            'cach_xep_mac_dinh' => $format['cach_xep_mac_dinh'],
            'seed_source_mac_dinh' => $format['seed_source_mac_dinh'],
            'mota' => $format['mota'],
            'trangthai' => $format['trangthai'],
        ]);
    }

    private function insertDefaultRounds(int $tournamentId, array $format, int $teamCount): void
    {
        $teamCount = max(2, $teamCount);
        $rounds = [];
        $order = 1;

        if ((int) ($format['co_vong_diem'] ?? 0) === 1) {
            $rounds[] = [
                'tenvongdau' => 'Vòng điểm',
                'loaivongdau' => 'VONG_DIEM',
                'thutu' => $order++,
                'so_doi_tham_gia' => $teamCount,
                'co_bangdau' => 0,
                'so_bang_dau' => 0,
                'so_luot_dau' => 1,
                'so_doi_vao_vong_sau' => (int) ($format['co_vong_loai'] ?? 0) === 1 ? min(8, $teamCount) : null,
                'so_doi_vao_moi_bang' => null,
                'cach_chon_doi_di_tiep' => (int) ($format['co_vong_loai'] ?? 0) === 1 ? 'TOP_N' : 'KHONG_AP_DUNG',
                'cach_xep_cap_dau' => 'KHONG_AP_DUNG',
                'seed_source' => 'KHONG_AP_DUNG',
                'co_tranh_hang_ba' => 0,
            ];
        }

        if ((int) ($format['co_vong_loai'] ?? 0) === 1) {
            $rounds[] = [
                'tenvongdau' => 'Vòng loại trực tiếp',
                'loaivongdau' => 'VONG_LOAI',
                'thutu' => $order,
                'so_doi_tham_gia' => min(8, $teamCount),
                'co_bangdau' => 0,
                'so_bang_dau' => 0,
                'so_luot_dau' => 1,
                'so_doi_vao_vong_sau' => null,
                'so_doi_vao_moi_bang' => null,
                'cach_chon_doi_di_tiep' => 'THANG_DI_TIEP',
                'cach_xep_cap_dau' => (string) ($format['cach_xep_mac_dinh'] ?? 'HYBRID'),
                'seed_source' => (string) ($format['seed_source_mac_dinh'] ?? 'KHONG_AP_DUNG'),
                'co_tranh_hang_ba' => (int) ($format['co_tranh_hang_ba'] ?? 0),
            ];
        }

        if ($rounds === []) {
            return;
        }

        $statement = $this->db()->prepare(
            "INSERT INTO Vongdau
                (idgiaidau, tenvongdau, loaivongdau, thutu, so_doi_tham_gia, co_bangdau, so_bang_dau, so_luot_dau, so_doi_vao_vong_sau, so_doi_vao_moi_bang, cach_chon_doi_di_tiep, cach_xep_cap_dau, seed_source, co_tranh_hang_ba, trangthai)
             VALUES
                (:tournament_id, :name, :type, :sort_order, :team_count, :has_groups, :group_count, :legs, :advance_count, :advance_per_group, :advance_rule, :pairing_rule, :seed_source, :has_third_place, 'NHAP')"
        );

        foreach ($rounds as $round) {
            $statement->execute([
                'tournament_id' => $tournamentId,
                'name' => $round['tenvongdau'],
                'type' => $round['loaivongdau'],
                'sort_order' => $round['thutu'],
                'team_count' => $round['so_doi_tham_gia'],
                'has_groups' => $round['co_bangdau'],
                'group_count' => $round['so_bang_dau'],
                'legs' => $round['so_luot_dau'],
                'advance_count' => $round['so_doi_vao_vong_sau'],
                'advance_per_group' => $round['so_doi_vao_moi_bang'],
                'advance_rule' => $round['cach_chon_doi_di_tiep'],
                'pairing_rule' => $round['cach_xep_cap_dau'],
                'seed_source' => $round['seed_source'],
                'has_third_place' => $round['co_tranh_hang_ba'],
            ]);
        }
    }

    private function insertTeamSelectionRule(int $tournamentId, array $rule): int
    {
        $statement = $this->db()->prepare(
            "INSERT INTO Quytacchondoi
                (idgiaidau, chedochondoi, capdoituongthamgia, yeu_cau_thanh_tich, idcapgiaidau_thanh_tich_nguon, hang_toi_thieu_duoc_phep, so_mua_giai_gan_nhat_duoc_tinh, cho_phep_btc_duyet_ngoai_le, soluongdoitoida, mota, trangthai)
             VALUES
                (:tournament_id, :chedochondoi, :capdoituongthamgia, :yeu_cau_thanh_tich, :idcapgiaidau_thanh_tich_nguon, :hang_toi_thieu_duoc_phep, :so_mua_giai_gan_nhat_duoc_tinh, :cho_phep_btc_duyet_ngoai_le, :soluongdoitoida, :mota, :trangthai)"
        );

        $statement->execute([
            'tournament_id' => $tournamentId,
            'chedochondoi' => $rule['chedochondoi'],
            'capdoituongthamgia' => $rule['capdoituongthamgia'],
            'yeu_cau_thanh_tich' => $rule['yeu_cau_thanh_tich'],
            'idcapgiaidau_thanh_tich_nguon' => $rule['idcapgiaidau_thanh_tich_nguon'],
            'hang_toi_thieu_duoc_phep' => $rule['hang_toi_thieu_duoc_phep'],
            'so_mua_giai_gan_nhat_duoc_tinh' => $rule['so_mua_giai_gan_nhat_duoc_tinh'],
            'cho_phep_btc_duyet_ngoai_le' => $rule['cho_phep_btc_duyet_ngoai_le'],
            'soluongdoitoida' => $rule['soluongdoitoida'],
            'mota' => $rule['mota'],
            'trangthai' => $rule['trangthai'],
        ]);

        return (int) $this->db()->lastInsertId();
    }

    private function insertParticipationConditions(int $tournamentId, int $teamSelectionRuleId, array $conditions): void
    {
        foreach ($conditions as $condition) {
            $this->insertParticipationCondition($tournamentId, $teamSelectionRuleId, $condition);
        }
    }

    private function insertParticipationCondition(int $tournamentId, int $teamSelectionRuleId, array $condition): void
    {
        $statement = $this->db()->prepare(
            "INSERT INTO Dieukienthamgiagiai
                (idgiaidau, idquytac, ten_dieukien, capdoituongthamgia, yeu_cau_thanh_tich, idcapgiaidau_thanh_tich_nguon, hang_toi_thieu_duoc_phep, so_mua_giai_gan_nhat_duoc_tinh, chi_tinh_giai_chinh_thuc, bat_buoc_cung_khuvuc, cho_phep_btc_duyet_ngoai_le, mota, trangthai)
             VALUES
                (:tournament_id, :team_selection_rule_id, :ten_dieukien, :capdoituongthamgia, :yeu_cau_thanh_tich, :idcapgiaidau_thanh_tich_nguon, :hang_toi_thieu_duoc_phep, :so_mua_giai_gan_nhat_duoc_tinh, :chi_tinh_giai_chinh_thuc, :bat_buoc_cung_khuvuc, :cho_phep_btc_duyet_ngoai_le, :mota, :trangthai)"
        );

        $statement->execute([
            'tournament_id' => $tournamentId,
            'team_selection_rule_id' => $teamSelectionRuleId,
            'ten_dieukien' => $condition['ten_dieukien'],
            'capdoituongthamgia' => $condition['capdoituongthamgia'],
            'yeu_cau_thanh_tich' => $condition['yeu_cau_thanh_tich'],
            'idcapgiaidau_thanh_tich_nguon' => $condition['idcapgiaidau_thanh_tich_nguon'],
            'hang_toi_thieu_duoc_phep' => $condition['hang_toi_thieu_duoc_phep'],
            'so_mua_giai_gan_nhat_duoc_tinh' => $condition['so_mua_giai_gan_nhat_duoc_tinh'],
            'chi_tinh_giai_chinh_thuc' => $condition['chi_tinh_giai_chinh_thuc'],
            'bat_buoc_cung_khuvuc' => $condition['bat_buoc_cung_khuvuc'],
            'cho_phep_btc_duyet_ngoai_le' => $condition['cho_phep_btc_duyet_ngoai_le'],
            'mota' => $condition['mota'],
            'trangthai' => $condition['trangthai'],
        ]);
    }

    private function updateTournamentFields(int $tournamentId, array $tournament): void
    {
        $sets = [];
        $bindings = ['tournament_id' => $tournamentId];
        $fields = ['tengiaidau', 'mota', 'idcapgiaidau', 'idkhuvucphamvi', 'idluat', 'thoigianbatdau', 'thoigianketthuc', 'quymo', 'hinhanh', 'tinhchat', 'ghichu_diadiem'];

        foreach ($fields as $field) {
            if (!array_key_exists($field, $tournament)) {
                continue;
            }

            $sets[] = "{$field} = :{$field}";
            $bindings[$field] = $tournament[$field];
        }

        if ($sets === []) {
            return;
        }

        $sets[] = 'ngaycapnhat = CURRENT_TIMESTAMP';

        $statement = $this->db()->prepare(
            'UPDATE Giaidau SET ' . implode(', ', $sets) . ' WHERE idgiaidau = :tournament_id'
        );

        $statement->execute($bindings);
    }

    private function replaceRegulations(int $tournamentId, array $regulation): void
    {
        $statement = $this->db()->prepare(
            "DELETE FROM Dieulegiaidau
             WHERE idgiaidau = :tournament_id"
        );
        $statement->execute(['tournament_id' => $tournamentId]);

        $this->insertRegulations($tournamentId, $regulation);
    }

    private function replaceCompetitionFormat(int $tournamentId, array $format): void
    {
        $statement = $this->db()->prepare(
            "DELETE FROM Thethucgiaidau
             WHERE idgiaidau = :tournament_id"
        );
        $statement->execute(['tournament_id' => $tournamentId]);

        $this->insertCompetitionFormat($tournamentId, $format);
        $this->replaceDefaultRoundsIfSafe($tournamentId, $format);
    }

    private function replaceDefaultRoundsIfSafe(int $tournamentId, array $format): void
    {
        $usage = $this->first(
            "SELECT
                COUNT(DISTINCT vd.idvongdau) AS total_rounds,
                COUNT(DISTINCT bd.idbangdau) AS total_groups,
                COUNT(DISTINCT td.idtrandau) AS total_matches,
                COUNT(DISTINCT dv.iddoitrongvong) AS total_round_teams
             FROM Vongdau vd
             LEFT JOIN Bangdau bd ON bd.idvongdau = vd.idvongdau
             LEFT JOIN Trandau td ON td.idvongdau = vd.idvongdau
             LEFT JOIN Doitrongvongdau dv ON dv.idvongdau = vd.idvongdau
             WHERE vd.idgiaidau = :tournament_id",
            ['tournament_id' => $tournamentId]
        );

        if (
            (int) ($usage['total_groups'] ?? 0) > 0
            || (int) ($usage['total_matches'] ?? 0) > 0
            || (int) ($usage['total_round_teams'] ?? 0) > 0
        ) {
            return;
        }

        $statement = $this->db()->prepare(
            "DELETE FROM Vongdau
             WHERE idgiaidau = :tournament_id"
        );
        $statement->execute(['tournament_id' => $tournamentId]);

        $tournament = $this->findById($tournamentId);

        if ($tournament === null) {
            return;
        }

        $this->insertDefaultRounds($tournamentId, $format, (int) $tournament['quymo']);
    }

    private function replaceTeamSelectionRule(int $tournamentId, array $rule, array $conditions): void
    {
        $statement = $this->db()->prepare(
            "UPDATE Quytacchondoi
             SET trangthai = 'NGUNG_SU_DUNG'
             WHERE idgiaidau = :tournament_id"
        );
        $statement->execute(['tournament_id' => $tournamentId]);

        $statement = $this->db()->prepare(
            "UPDATE Dieukienthamgiagiai
             SET trangthai = 'NGUNG_SU_DUNG',
                 ngaycapnhat = CURRENT_TIMESTAMP
             WHERE idgiaidau = :tournament_id"
        );
        $statement->execute(['tournament_id' => $tournamentId]);

        $teamSelectionRuleId = $this->insertTeamSelectionRule($tournamentId, $rule);
        $this->insertParticipationConditions($tournamentId, $teamSelectionRuleId, $conditions);
    }

    private function registrationRequestMarker(int $tournamentId, int $teamId): string
    {
        return 'Dang ky giai dau #' . $tournamentId . ', doi #' . $teamId . '.';
    }

    private function findPendingTournamentRegistrationRequest(int $registrationId): ?array
    {
        return $this->first(
            "SELECT yc.idyeucau
             FROM Dangkygiaidau dk
             JOIN Giaidau gd ON gd.idgiaidau = dk.idgiaidau
             JOIN Yeucauxacnhan yc
               ON yc.loainguoigui = 'HUAN_LUYEN_VIEN'
              AND yc.idnguoigui = dk.idhuanluyenvien
              AND yc.loainguoinhan = 'BAN_TO_CHUC'
              AND yc.idnguoinhan = gd.idbantochuc
              AND yc.loaixacnhan = 'XAC_NHAN_DANG_KY_GIAI'
              AND yc.trangthai = 'CHO_DUYET'
              AND yc.noidung LIKE CONCAT('Dang ky giai dau #', dk.idgiaidau, ', doi #', dk.iddoibong, '.%')
             WHERE dk.iddangky = :registration_id
             ORDER BY yc.idyeucau DESC
             LIMIT 1",
            ['registration_id' => $registrationId]
        );
    }

    private function recordSystemLog(?int $accountId, string $action, string $targetTable, ?int $targetId, ?string $ipAddress, ?string $note = null): void
    {
        $statement = $this->db()->prepare(
            "INSERT INTO Nhatkyhethong (idtaikhoan, hanhdong, bangtacdong, iddoituong, ipaddress, ghichu)
             VALUES (:account_id, :action, :target_table, :target_id, :ip_address, :note)"
        );

        $statement->execute([
            'account_id' => $accountId,
            'action' => $action,
            'target_table' => $targetTable,
            'target_id' => $targetId,
            'ip_address' => $ipAddress,
            'note' => $note,
        ]);
    }

    private function recordStatusHistory(string $targetType, int $targetId, ?string $oldStatus, string $newStatus, ?string $reason, ?int $actorId): void
    {
        $statement = $this->db()->prepare(
            "INSERT INTO Nhatkytrangthai (loaidoituong, iddoituong, trangthaicu, trangthaimoi, lydo, idnguoithuchien)
             VALUES (:target_type, :target_id, :old_status, :new_status, :reason, :actor_id)"
        );

        $statement->execute([
            'target_type' => $targetType,
            'target_id' => $targetId,
            'old_status' => $oldStatus,
            'new_status' => $newStatus,
            'reason' => $reason,
            'actor_id' => $actorId,
        ]);
    }
}
