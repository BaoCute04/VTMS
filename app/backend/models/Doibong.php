<?php

declare(strict_types=1);

namespace App\Backend\Models;

use App\Backend\Core\Model;
use Throwable;

final class Doibong extends Model
{
    public function coachByAccountId(int $accountId): ?array
    {
        return $this->first(
            "SELECT
                hlv.idhuanluyenvien,
                hlv.idnguoidung,
                hlv.bangcap,
                hlv.kinhnghiem,
                hlv.idkhuvuccongtac,
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

    public function teamNameExists(string $name, ?int $excludeTeamId = null): bool
    {
        $bindings = ['name' => $name];
        $sql = 'SELECT 1 FROM Doibong WHERE tendoibong = :name';

        if ($excludeTeamId !== null) {
            $sql .= ' AND iddoibong <> :exclude_team_id';
            $bindings['exclude_team_id'] = $excludeTeamId;
        }

        return $this->first($sql . ' LIMIT 1', $bindings) !== null;
    }

    public function listForCoach(int $coachId, array $filters = []): array
    {
        $where = ['db.idhuanluyenvien = :coach_id'];
        $bindings = ['coach_id' => $coachId];

        if (($filters['status'] ?? '') !== '') {
            $where[] = 'db.trangthai = :status';
            $bindings['status'] = $filters['status'];
        }

        if (($filters['q'] ?? '') !== '') {
            $where[] = "CONCAT_WS(' ', db.tendoibong, db.diaphuong, db.mota) LIKE :keyword";
            $bindings['keyword'] = '%' . $filters['q'] . '%';
        }

        $statement = $this->db()->prepare(
            "SELECT
                db.iddoibong,
                db.tendoibong,
                db.logo,
                db.idkhuvucdaidien,
                db.idcapgiaidau_duoc_tham_gia,
                db.diaphuong,
                db.mota,
                db.idhuanluyenvien,
                db.trangthai,
                db.ngaytao,
                db.ngaycapnhat,
                cgnguon.idcapgiaidau AS idcapgiaidau_nguon,
                cgnguon.macapgiaidau AS macapgiaidau_nguon,
                cgnguon.tencapgiaidau AS tencapgiaidau_nguon,
                cgtiep.macapgiaidau AS macapgiaidau_duoc_tham_gia,
                cgtiep.tencapgiaidau AS tencapgiaidau_duoc_tham_gia,
                COALESCE(cgtiep.idcapgiaidau, cgnguon.idcapgiaidau) AS idcapgiaidau_hien_tai,
                COALESCE(cgtiep.macapgiaidau, cgnguon.macapgiaidau) AS macapgiaidau_hien_tai,
                COALESCE(cgtiep.tencapgiaidau, cgnguon.tencapgiaidau) AS tencapgiaidau_hien_tai,
                dctt.iddecu AS iddecu_thi_tiep,
                dctt.trangthai AS trangthai_decu_thi_tiep,
                dcgiai.idgiaidau_decu_tham_gia,
                dcgiai.tengiaidau_decu_tham_gia,
                dctt.idcapgiaidau_dich AS idcapgiaidau_thi_tiep,
                cgdectiep.macapgiaidau AS macapgiaidau_thi_tiep,
                cgdectiep.tencapgiaidau AS tencapgiaidau_thi_tiep,
                COALESCE(tv.total_members, 0) AS total_members,
                COALESCE(tv.active_members, 0) AS active_members,
                COALESCE(dk.total_registrations, 0) AS total_registrations,
                COALESCE(dk.approved_registrations, 0) AS approved_registrations
             FROM Doibong db
             LEFT JOIN Khuvuc kv ON kv.idkhuvuc = db.idkhuvucdaidien
             LEFT JOIN Capgiaidau cgnguon ON cgnguon.macapgiaidau = kv.capkhuvuc
             LEFT JOIN Capgiaidau cgtiep ON cgtiep.idcapgiaidau = db.idcapgiaidau_duoc_tham_gia
             LEFT JOIN decutucachthamgia dctt ON dctt.iddecu = (
                SELECT dc2.iddecu
                FROM decutucachthamgia dc2
                WHERE dc2.iddoibong = db.iddoibong
                  AND dc2.trangthai IN ('DU_DIEU_KIEN', 'DA_DE_CU', 'DA_XAC_NHAN')
                ORDER BY FIELD(dc2.trangthai, 'DA_XAC_NHAN', 'DA_DE_CU', 'DU_DIEU_KIEN'),
                         dc2.ngaycapnhat DESC,
                         dc2.ngay_xacnhan DESC,
                         dc2.ngay_decu DESC,
                         dc2.ngay_danhdau DESC,
                         dc2.iddecu DESC
                LIMIT 1
             )
             LEFT JOIN (
                SELECT
                    grouped.iddoibong,
                    GROUP_CONCAT(grouped.idgiaidau_dich ORDER BY grouped.thoigianbatdau ASC, grouped.idgiaidau_dich ASC SEPARATOR ',') AS idgiaidau_decu_tham_gia,
                    GROUP_CONCAT(grouped.tengiaidau ORDER BY grouped.thoigianbatdau ASC, grouped.idgiaidau_dich ASC SEPARATOR ', ') AS tengiaidau_decu_tham_gia
                FROM (
                    SELECT DISTINCT
                        dc2.iddoibong,
                        dc2.idgiaidau_dich,
                        gd2.tengiaidau,
                        gd2.thoigianbatdau
                    FROM decutucachthamgia dc2
                    JOIN Giaidau gd2 ON gd2.idgiaidau = dc2.idgiaidau_dich
                    WHERE dc2.trangthai IN ('DU_DIEU_KIEN', 'DA_DE_CU', 'DA_XAC_NHAN')
                ) grouped
                GROUP BY grouped.iddoibong
             ) dcgiai ON dcgiai.iddoibong = db.iddoibong
             LEFT JOIN Capgiaidau cgdectiep ON cgdectiep.idcapgiaidau = dctt.idcapgiaidau_dich
             LEFT JOIN (
                SELECT
                    iddoibong,
                    COUNT(*) AS total_members,
                    SUM(CASE WHEN trangthai = 'DANG_THAM_GIA' THEN 1 ELSE 0 END) AS active_members
                FROM Thanhviendoibong
                GROUP BY iddoibong
             ) tv ON tv.iddoibong = db.iddoibong
             LEFT JOIN (
                SELECT
                    iddoibong,
                    COUNT(*) AS total_registrations,
                    SUM(CASE WHEN trangthai = 'DA_DUYET' THEN 1 ELSE 0 END) AS approved_registrations
                FROM Dangkygiaidau
                GROUP BY iddoibong
             ) dk ON dk.iddoibong = db.iddoibong
             WHERE " . implode(' AND ', $where) . "
             ORDER BY db.ngaytao DESC, db.iddoibong DESC"
        );

        $statement->execute($bindings);

        return $statement->fetchAll();
    }

    public function findForCoach(int $coachId, int $teamId): ?array
    {
        return $this->first(
            "SELECT
                db.iddoibong,
                db.tendoibong,
                db.logo,
                db.idkhuvucdaidien,
                db.idcapgiaidau_duoc_tham_gia,
                db.diaphuong,
                db.mota,
                db.idhuanluyenvien,
                db.trangthai,
                db.ngaytao,
                db.ngaycapnhat,
                cgnguon.idcapgiaidau AS idcapgiaidau_nguon,
                cgnguon.macapgiaidau AS macapgiaidau_nguon,
                cgnguon.tencapgiaidau AS tencapgiaidau_nguon,
                cgtiep.macapgiaidau AS macapgiaidau_duoc_tham_gia,
                cgtiep.tencapgiaidau AS tencapgiaidau_duoc_tham_gia,
                COALESCE(cgtiep.idcapgiaidau, cgnguon.idcapgiaidau) AS idcapgiaidau_hien_tai,
                COALESCE(cgtiep.macapgiaidau, cgnguon.macapgiaidau) AS macapgiaidau_hien_tai,
                COALESCE(cgtiep.tencapgiaidau, cgnguon.tencapgiaidau) AS tencapgiaidau_hien_tai,
                dctt.iddecu AS iddecu_thi_tiep,
                dctt.trangthai AS trangthai_decu_thi_tiep,
                dcgiai.idgiaidau_decu_tham_gia,
                dcgiai.tengiaidau_decu_tham_gia,
                dctt.idcapgiaidau_dich AS idcapgiaidau_thi_tiep,
                cgdectiep.macapgiaidau AS macapgiaidau_thi_tiep,
                cgdectiep.tencapgiaidau AS tencapgiaidau_thi_tiep
             FROM Doibong db
             LEFT JOIN Khuvuc kv ON kv.idkhuvuc = db.idkhuvucdaidien
             LEFT JOIN Capgiaidau cgnguon ON cgnguon.macapgiaidau = kv.capkhuvuc
             LEFT JOIN Capgiaidau cgtiep ON cgtiep.idcapgiaidau = db.idcapgiaidau_duoc_tham_gia
             LEFT JOIN decutucachthamgia dctt ON dctt.iddecu = (
                SELECT dc2.iddecu
                FROM decutucachthamgia dc2
                WHERE dc2.iddoibong = db.iddoibong
                  AND dc2.trangthai IN ('DU_DIEU_KIEN', 'DA_DE_CU', 'DA_XAC_NHAN')
                ORDER BY FIELD(dc2.trangthai, 'DA_XAC_NHAN', 'DA_DE_CU', 'DU_DIEU_KIEN'),
                         dc2.ngaycapnhat DESC,
                         dc2.ngay_xacnhan DESC,
                         dc2.ngay_decu DESC,
                         dc2.ngay_danhdau DESC,
                         dc2.iddecu DESC
                LIMIT 1
             )
             LEFT JOIN (
                SELECT
                    grouped.iddoibong,
                    GROUP_CONCAT(grouped.idgiaidau_dich ORDER BY grouped.thoigianbatdau ASC, grouped.idgiaidau_dich ASC SEPARATOR ',') AS idgiaidau_decu_tham_gia,
                    GROUP_CONCAT(grouped.tengiaidau ORDER BY grouped.thoigianbatdau ASC, grouped.idgiaidau_dich ASC SEPARATOR ', ') AS tengiaidau_decu_tham_gia
                FROM (
                    SELECT DISTINCT
                        dc2.iddoibong,
                        dc2.idgiaidau_dich,
                        gd2.tengiaidau,
                        gd2.thoigianbatdau
                    FROM decutucachthamgia dc2
                    JOIN Giaidau gd2 ON gd2.idgiaidau = dc2.idgiaidau_dich
                    WHERE dc2.trangthai IN ('DU_DIEU_KIEN', 'DA_DE_CU', 'DA_XAC_NHAN')
                ) grouped
                GROUP BY grouped.iddoibong
             ) dcgiai ON dcgiai.iddoibong = db.iddoibong
             LEFT JOIN Capgiaidau cgdectiep ON cgdectiep.idcapgiaidau = dctt.idcapgiaidau_dich
             WHERE db.iddoibong = :team_id
               AND db.idhuanluyenvien = :coach_id
             LIMIT 1",
            [
                'team_id' => $teamId,
                'coach_id' => $coachId,
            ]
        );
    }

    public function createForCoach(array $team, int $coachId, int $actorAccountId, ?string $ipAddress, string $logNote): int
    {
        $db = $this->db();

        try {
            $db->beginTransaction();

            $statement = $db->prepare(
                "INSERT INTO Doibong (tendoibong, logo, idkhuvucdaidien, diaphuong, mota, idhuanluyenvien, trangthai)
                 VALUES (:name, :logo, :representative_region_id, :local, :description, :coach_id, :status)"
            );
            $statement->execute([
                'name' => $team['tendoibong'],
                'logo' => $team['logo'],
                'representative_region_id' => $team['idkhuvucdaidien'],
                'local' => $team['diaphuong'],
                'description' => $team['mota'],
                'coach_id' => $coachId,
                'status' => $team['trangthai'],
            ]);

            $teamId = (int) $db->lastInsertId();

            $this->recordStatusHistory('DOI_BONG', $teamId, null, (string) $team['trangthai'], 'HLV tao doi bong', $actorAccountId);
            $this->recordSystemLog($actorAccountId, 'Tao doi bong', 'Doibong', $teamId, $ipAddress, $logNote);

            $db->commit();

            return $teamId;
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    public function teamsForTournament(int $tournamentId, array $filters = []): array
    {
        $where = ['dk.idgiaidau = :tournament_id'];
        $bindings = ['tournament_id' => $tournamentId];

        if (($filters['registration_status'] ?? '') !== '') {
            $where[] = 'dk.trangthai = :registration_status';
            $bindings['registration_status'] = $filters['registration_status'];
        }

        if (($filters['team_status'] ?? '') !== '') {
            $where[] = 'db.trangthai = :team_status';
            $bindings['team_status'] = $filters['team_status'];
        }

        if (($filters['q'] ?? '') !== '') {
            $where[] = "(db.tendoibong LIKE :keyword
                OR db.diaphuong LIKE :keyword
                OR TRIM(CONCAT(COALESCE(nd.hodem, ''), ' ', COALESCE(nd.ten, ''))) LIKE :keyword
                OR tk.username LIKE :keyword)";
            $bindings['keyword'] = '%' . $filters['q'] . '%';
        }

        $statement = $this->db()->prepare(
            "SELECT
                dk.iddangky,
                dk.idgiaidau,
                dk.iddoibong,
                dk.idhuanluyenvien,
                dk.ngaydangky,
                dk.trangthai AS trangthaidangky,
                dk.lydotuchoi,
                db.tendoibong,
                db.logo,
                db.diaphuong,
                db.mota,
                db.trangthai AS trangthaidoibong,
                db.ngaytao AS doibong_ngaytao,
                db.ngaycapnhat AS doibong_ngaycapnhat,
                hlv.bangcap AS huanluyenvien_bangcap,
                hlv.kinhnghiem AS huanluyenvien_kinhnghiem,
                hlv.trangthai AS huanluyenvien_trangthai,
                nd.idnguoidung AS huanluyenvien_idnguoidung,
                TRIM(CONCAT(COALESCE(nd.hodem, ''), ' ', COALESCE(nd.ten, ''))) AS huanluyenvien_hoten,
                tk.username AS huanluyenvien_username,
                tk.email AS huanluyenvien_email,
                COALESCE(tv_stats.total_members, 0) AS total_members,
                COALESCE(tv_stats.active_members, 0) AS active_members,
                COALESCE(dh_stats.total_lineups, 0) AS total_lineups,
                COALESCE(dh_stats.locked_lineups, 0) AS locked_lineups
             FROM Dangkygiaidau dk
             JOIN Doibong db ON db.iddoibong = dk.iddoibong
             JOIN Huanluyenvien hlv ON hlv.idhuanluyenvien = dk.idhuanluyenvien
             JOIN Nguoidung nd ON nd.idnguoidung = hlv.idnguoidung
             JOIN Taikhoan tk ON tk.idtaikhoan = nd.idtaikhoan
             LEFT JOIN (
                SELECT
                    iddoibong,
                    COUNT(*) AS total_members,
                    SUM(CASE WHEN trangthai = 'DANG_THAM_GIA' THEN 1 ELSE 0 END) AS active_members
                FROM Thanhviendoibong
                GROUP BY iddoibong
             ) tv_stats ON tv_stats.iddoibong = dk.iddoibong
             LEFT JOIN (
                SELECT
                    iddoibong,
                    idgiaidau,
                    COUNT(*) AS total_lineups,
                    SUM(CASE WHEN trangthai = 'DA_CHOT' THEN 1 ELSE 0 END) AS locked_lineups
                FROM Doihinh
                GROUP BY iddoibong, idgiaidau
             ) dh_stats ON dh_stats.iddoibong = dk.iddoibong AND dh_stats.idgiaidau = dk.idgiaidau
             WHERE " . implode(' AND ', $where) . "
             ORDER BY dk.ngaydangky DESC, dk.iddangky DESC"
        );

        $statement->execute($bindings);

        return $statement->fetchAll();
    }

    public function teamsForOrganizer(int $organizerId, array $filters = []): array
    {
        $where = ['gd.idbantochuc = :organizer_id'];
        $bindings = ['organizer_id' => $organizerId];

        if (($filters['tournament_id'] ?? '') !== '') {
            $where[] = 'dk.idgiaidau = :tournament_id';
            $bindings['tournament_id'] = (int) $filters['tournament_id'];
        }

        if (($filters['registration_status'] ?? '') !== '') {
            $where[] = 'dk.trangthai = :registration_status';
            $bindings['registration_status'] = $filters['registration_status'];
        }

        if (($filters['team_status'] ?? '') !== '') {
            $where[] = 'db.trangthai = :team_status';
            $bindings['team_status'] = $filters['team_status'];
        }

        if (($filters['q'] ?? '') !== '') {
            $where[] = "(db.tendoibong LIKE :keyword
                OR db.diaphuong LIKE :keyword
                OR gd.tengiaidau LIKE :keyword
                OR TRIM(CONCAT(COALESCE(nd.hodem, ''), ' ', COALESCE(nd.ten, ''))) LIKE :keyword
                OR tk.username LIKE :keyword)";
            $bindings['keyword'] = '%' . $filters['q'] . '%';
        }

        $statement = $this->db()->prepare(
            "SELECT
                dk.iddangky,
                dk.idgiaidau,
                dk.iddoibong,
                dk.idhuanluyenvien,
                dk.ngaydangky,
                dk.trangthai AS trangthaidangky,
                dk.lydotuchoi,
                gd.tengiaidau,
                gd.trangthai AS trangthaigiaidau,
                db.tendoibong,
                db.logo,
                db.diaphuong,
                db.mota,
                db.trangthai AS trangthaidoibong,
                db.ngaytao AS doibong_ngaytao,
                db.ngaycapnhat AS doibong_ngaycapnhat,
                hlv.bangcap AS huanluyenvien_bangcap,
                hlv.kinhnghiem AS huanluyenvien_kinhnghiem,
                hlv.trangthai AS huanluyenvien_trangthai,
                nd.idnguoidung AS huanluyenvien_idnguoidung,
                TRIM(CONCAT(COALESCE(nd.hodem, ''), ' ', COALESCE(nd.ten, ''))) AS huanluyenvien_hoten,
                tk.username AS huanluyenvien_username,
                tk.email AS huanluyenvien_email,
                COALESCE(tv_stats.total_members, 0) AS total_members,
                COALESCE(tv_stats.active_members, 0) AS active_members,
                COALESCE(dh_stats.total_lineups, 0) AS total_lineups,
                COALESCE(dh_stats.locked_lineups, 0) AS locked_lineups
             FROM Dangkygiaidau dk
             JOIN Giaidau gd ON gd.idgiaidau = dk.idgiaidau
             JOIN Doibong db ON db.iddoibong = dk.iddoibong
             JOIN Huanluyenvien hlv ON hlv.idhuanluyenvien = dk.idhuanluyenvien
             JOIN Nguoidung nd ON nd.idnguoidung = hlv.idnguoidung
             JOIN Taikhoan tk ON tk.idtaikhoan = nd.idtaikhoan
             LEFT JOIN (
                SELECT
                    iddoibong,
                    COUNT(*) AS total_members,
                    SUM(CASE WHEN trangthai = 'DANG_THAM_GIA' THEN 1 ELSE 0 END) AS active_members
                FROM Thanhviendoibong
                GROUP BY iddoibong
             ) tv_stats ON tv_stats.iddoibong = dk.iddoibong
             LEFT JOIN (
                SELECT
                    iddoibong,
                    idgiaidau,
                    COUNT(*) AS total_lineups,
                    SUM(CASE WHEN trangthai = 'DA_CHOT' THEN 1 ELSE 0 END) AS locked_lineups
                FROM Doihinh
                GROUP BY iddoibong, idgiaidau
             ) dh_stats ON dh_stats.iddoibong = dk.iddoibong AND dh_stats.idgiaidau = dk.idgiaidau
             WHERE " . implode(' AND ', $where) . "
             ORDER BY dk.ngaydangky DESC, dk.iddangky DESC"
        );

        $statement->execute($bindings);

        return $statement->fetchAll();
    }

    public function teamContextForOrganizer(int $organizerId, int $teamId, ?int $tournamentId = null): ?array
    {
        $bindings = [
            'organizer_id' => $organizerId,
            'team_id' => $teamId,
        ];
        $tournamentCondition = '';

        if ($tournamentId !== null) {
            $tournamentCondition = ' AND dk.idgiaidau = :tournament_id';
            $bindings['tournament_id'] = $tournamentId;
        }

        return $this->first(
            "SELECT
                dk.iddangky,
                dk.idgiaidau,
                dk.trangthai AS trangthaidangky,
                gd.tengiaidau,
                gd.idbantochuc,
                db.iddoibong,
                db.tendoibong,
                db.logo,
                db.diaphuong,
                db.mota,
                db.trangthai AS trangthaidoibong
             FROM Dangkygiaidau dk
             JOIN Giaidau gd ON gd.idgiaidau = dk.idgiaidau
             JOIN Doibong db ON db.iddoibong = dk.iddoibong
             WHERE gd.idbantochuc = :organizer_id
               AND dk.iddoibong = :team_id" . $tournamentCondition . "
             ORDER BY dk.ngaydangky DESC, dk.iddangky DESC
             LIMIT 1",
            $bindings
        );
    }

    public function updateTeamProfile(
        int $teamId,
        array $changes,
        string $oldStatus,
        ?string $newStatus,
        int $actorAccountId,
        ?string $ipAddress,
        string $logNote
    ): void {
        $db = $this->db();
        $sets = [];
        $bindings = ['team_id' => $teamId];

        foreach ($changes as $field => $value) {
            $sets[] = "{$field} = :{$field}";
            $bindings[$field] = $value;
        }

        $sets[] = 'ngaycapnhat = CURRENT_TIMESTAMP';

        try {
            $db->beginTransaction();

            $statement = $db->prepare(
                'UPDATE Doibong SET ' . implode(', ', $sets) . ' WHERE iddoibong = :team_id'
            );

            $statement->execute($bindings);

            if ($statement->rowCount() !== 1) {
                throw new \RuntimeException('TEAM_PROFILE_NOT_UPDATED');
            }

            $this->recordSystemLog($actorAccountId, 'Cap nhat ho so doi bong', 'Doibong', $teamId, $ipAddress, $logNote);

            if ($newStatus !== null && $newStatus !== $oldStatus) {
                $this->recordStatusHistory('DOI_BONG', $teamId, $oldStatus, $newStatus, 'Cap nhat trang thai doi bong', $actorAccountId);
            }

            $db->commit();
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    public function teamProfileForTournament(int $tournamentId, int $teamId): ?array
    {
        return $this->first(
            "SELECT
                dk.iddangky,
                dk.idgiaidau,
                dk.iddoibong,
                dk.idhuanluyenvien,
                dk.ngaydangky,
                dk.trangthai AS trangthaidangky,
                dk.lydotuchoi,
                gd.tengiaidau,
                gd.trangthai AS trangthaigiaidau,
                gd.trangthaidangky AS trangthaidangkygiaidau,
                db.tendoibong,
                db.logo,
                db.diaphuong,
                db.mota,
                db.trangthai AS trangthaidoibong,
                db.ngaytao AS doibong_ngaytao,
                db.ngaycapnhat AS doibong_ngaycapnhat,
                hlv.bangcap AS huanluyenvien_bangcap,
                hlv.kinhnghiem AS huanluyenvien_kinhnghiem,
                hlv.trangthai AS huanluyenvien_trangthai,
                nd.idnguoidung AS huanluyenvien_idnguoidung,
                nd.hodem AS huanluyenvien_hodem,
                nd.ten AS huanluyenvien_ten,
                nd.gioitinh AS huanluyenvien_gioitinh,
                nd.ngaysinh AS huanluyenvien_ngaysinh,
                nd.quequan AS huanluyenvien_quequan,
                nd.diachi AS huanluyenvien_diachi,
                nd.avatar AS huanluyenvien_avatar,
                TRIM(CONCAT(COALESCE(nd.hodem, ''), ' ', COALESCE(nd.ten, ''))) AS huanluyenvien_hoten,
                tk.username AS huanluyenvien_username,
                tk.email AS huanluyenvien_email,
                tk.sodienthoai AS huanluyenvien_sodienthoai
             FROM Dangkygiaidau dk
             JOIN Giaidau gd ON gd.idgiaidau = dk.idgiaidau
             JOIN Doibong db ON db.iddoibong = dk.iddoibong
             JOIN Huanluyenvien hlv ON hlv.idhuanluyenvien = dk.idhuanluyenvien
             JOIN Nguoidung nd ON nd.idnguoidung = hlv.idnguoidung
             JOIN Taikhoan tk ON tk.idtaikhoan = nd.idtaikhoan
             WHERE dk.idgiaidau = :tournament_id
               AND dk.iddoibong = :team_id
             LIMIT 1",
            [
                'tournament_id' => $tournamentId,
                'team_id' => $teamId,
            ]
        );
    }

    public function teamProfileForHigherEligibility(int $teamId): ?array
    {
        return $this->first(
            "SELECT
                db.iddoibong,
                db.idhuanluyenvien,
                db.tendoibong,
                db.logo,
                db.diaphuong,
                db.mota,
                db.trangthai AS trangthaidoibong,
                db.ngaytao AS doibong_ngaytao,
                db.ngaycapnhat AS doibong_ngaycapnhat,
                hlv.bangcap AS huanluyenvien_bangcap,
                hlv.kinhnghiem AS huanluyenvien_kinhnghiem,
                hlv.trangthai AS huanluyenvien_trangthai,
                nd.idnguoidung AS huanluyenvien_idnguoidung,
                nd.hodem AS huanluyenvien_hodem,
                nd.ten AS huanluyenvien_ten,
                nd.gioitinh AS huanluyenvien_gioitinh,
                nd.ngaysinh AS huanluyenvien_ngaysinh,
                nd.quequan AS huanluyenvien_quequan,
                nd.diachi AS huanluyenvien_diachi,
                nd.avatar AS huanluyenvien_avatar,
                TRIM(CONCAT(COALESCE(nd.hodem, ''), ' ', COALESCE(nd.ten, ''))) AS huanluyenvien_hoten,
                tk.username AS huanluyenvien_username,
                tk.email AS huanluyenvien_email,
                tk.sodienthoai AS huanluyenvien_sodienthoai
             FROM Doibong db
             JOIN Huanluyenvien hlv ON hlv.idhuanluyenvien = db.idhuanluyenvien
             JOIN Nguoidung nd ON nd.idnguoidung = hlv.idnguoidung
             JOIN Taikhoan tk ON tk.idtaikhoan = nd.idtaikhoan
             WHERE db.iddoibong = :team_id
             LIMIT 1",
            ['team_id' => $teamId]
        );
    }

    public function membersForTeam(int $teamId): array
    {
        $statement = $this->db()->prepare(
            "SELECT
                tv.idthanhvien,
                tv.iddoibong,
                tv.idvandongvien,
                tv.vaitro AS vaitrotrongdoi,
                tv.trangthai AS trangthaithanhvien,
                tv.ngaythamgia,
                tv.ngayroi,
                vdv.mavandongvien,
                vdv.chieucao,
                vdv.cannang,
                vdv.vitri,
                vdv.trangthaidaugiai,
                nd.idnguoidung,
                nd.hodem,
                nd.ten,
                nd.gioitinh,
                nd.ngaysinh,
                nd.quequan,
                nd.diachi,
                nd.avatar,
                TRIM(CONCAT(COALESCE(nd.hodem, ''), ' ', COALESCE(nd.ten, ''))) AS hoten,
                tk.username,
                tk.email,
                tk.sodienthoai
             FROM Thanhviendoibong tv
             JOIN Vandongvien vdv ON vdv.idvandongvien = tv.idvandongvien
             JOIN Nguoidung nd ON nd.idnguoidung = vdv.idnguoidung
             JOIN Taikhoan tk ON tk.idtaikhoan = nd.idtaikhoan
             WHERE tv.iddoibong = :team_id
             ORDER BY
                CASE tv.vaitro
                    WHEN 'DOI_TRUONG' THEN 1
                    WHEN 'THANH_VIEN' THEN 2
                    ELSE 3
                END,
                nd.ten,
                nd.hodem"
        );

        $statement->execute(['team_id' => $teamId]);

        return $statement->fetchAll();
    }

    public function listForSpectator(array $filters = []): array
    {
        $where = ["db.trangthai = 'HOAT_DONG'"];
        $bindings = [];

        if (($filters['q'] ?? '') !== '') {
            $where[] = "(db.tendoibong LIKE :keyword
                OR db.diaphuong LIKE :keyword
                OR db.mota LIKE :keyword
                OR TRIM(CONCAT(COALESCE(nd.hodem, ''), ' ', COALESCE(nd.ten, ''))) LIKE :keyword
                OR tk.username LIKE :keyword)";
            $bindings['keyword'] = '%' . $filters['q'] . '%';
        }

        if (($filters['tournament_id'] ?? null) !== null) {
            $where[] = "EXISTS (
                SELECT 1
                FROM Dangkygiaidau dk_filter
                JOIN Giaidau gd_filter ON gd_filter.idgiaidau = dk_filter.idgiaidau
                WHERE dk_filter.iddoibong = db.iddoibong
                  AND dk_filter.idgiaidau = :tournament_id
                  AND dk_filter.trangthai = 'DA_DUYET'
                  AND gd_filter.trangthai IN ('DA_CONG_BO', 'DANG_DIEN_RA', 'DA_KET_THUC')
            )";
            $bindings['tournament_id'] = (int) $filters['tournament_id'];
        }

        if (($filters['local'] ?? '') !== '') {
            $where[] = 'db.diaphuong LIKE :local';
            $bindings['local'] = '%' . $filters['local'] . '%';
        }

        $statement = $this->db()->prepare(
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
                hlv.bangcap AS huanluyenvien_bangcap,
                hlv.kinhnghiem AS huanluyenvien_kinhnghiem,
                hlv.trangthai AS huanluyenvien_trangthai,
                TRIM(CONCAT(COALESCE(nd.hodem, ''), ' ', COALESCE(nd.ten, ''))) AS huanluyenvien_hoten,
                tk.username AS huanluyenvien_username,
                COALESCE(member_stats.active_members, 0) AS active_members,
                COALESCE(tournament_stats.public_tournaments, 0) AS public_tournaments
             FROM Doibong db
             JOIN Huanluyenvien hlv ON hlv.idhuanluyenvien = db.idhuanluyenvien
             JOIN Nguoidung nd ON nd.idnguoidung = hlv.idnguoidung
             JOIN Taikhoan tk ON tk.idtaikhoan = nd.idtaikhoan
             LEFT JOIN (
                SELECT iddoibong, COUNT(*) AS active_members
                FROM Thanhviendoibong
                WHERE trangthai = 'DANG_THAM_GIA'
                GROUP BY iddoibong
             ) member_stats ON member_stats.iddoibong = db.iddoibong
             LEFT JOIN (
                SELECT dk.iddoibong, COUNT(*) AS public_tournaments
                FROM Dangkygiaidau dk
                JOIN Giaidau gd ON gd.idgiaidau = dk.idgiaidau
                WHERE dk.trangthai = 'DA_DUYET'
                  AND gd.trangthai IN ('DA_CONG_BO', 'DANG_DIEN_RA', 'DA_KET_THUC')
                GROUP BY dk.iddoibong
             ) tournament_stats ON tournament_stats.iddoibong = db.iddoibong
             WHERE " . implode(' AND ', $where) . "
             ORDER BY db.tendoibong, db.iddoibong"
        );

        $statement->execute($bindings);

        return $statement->fetchAll();
    }

    public function findClubForSpectator(int $teamId): ?array
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
                hlv.bangcap AS huanluyenvien_bangcap,
                hlv.kinhnghiem AS huanluyenvien_kinhnghiem,
                hlv.trangthai AS huanluyenvien_trangthai,
                nd.idnguoidung AS huanluyenvien_idnguoidung,
                TRIM(CONCAT(COALESCE(nd.hodem, ''), ' ', COALESCE(nd.ten, ''))) AS huanluyenvien_hoten,
                nd.avatar AS huanluyenvien_avatar,
                tk.username AS huanluyenvien_username,
                COALESCE(member_stats.active_members, 0) AS active_members,
                COALESCE(tournament_stats.public_tournaments, 0) AS public_tournaments
             FROM Doibong db
             JOIN Huanluyenvien hlv ON hlv.idhuanluyenvien = db.idhuanluyenvien
             JOIN Nguoidung nd ON nd.idnguoidung = hlv.idnguoidung
             JOIN Taikhoan tk ON tk.idtaikhoan = nd.idtaikhoan
             LEFT JOIN (
                SELECT iddoibong, COUNT(*) AS active_members
                FROM Thanhviendoibong
                WHERE trangthai = 'DANG_THAM_GIA'
                GROUP BY iddoibong
             ) member_stats ON member_stats.iddoibong = db.iddoibong
             LEFT JOIN (
                SELECT dk.iddoibong, COUNT(*) AS public_tournaments
                FROM Dangkygiaidau dk
                JOIN Giaidau gd ON gd.idgiaidau = dk.idgiaidau
                WHERE dk.trangthai = 'DA_DUYET'
                  AND gd.trangthai IN ('DA_CONG_BO', 'DANG_DIEN_RA', 'DA_KET_THUC')
                GROUP BY dk.iddoibong
             ) tournament_stats ON tournament_stats.iddoibong = db.iddoibong
             WHERE db.iddoibong = :team_id
               AND db.trangthai = 'HOAT_DONG'
             LIMIT 1",
            ['team_id' => $teamId]
        );
    }

    public function clubMembersForSpectator(int $teamId): array
    {
        $statement = $this->db()->prepare(
            "SELECT
                tv.idthanhvien,
                tv.iddoibong,
                tv.idvandongvien,
                tv.vaitro AS vaitrotrongdoi,
                tv.trangthai AS trangthaithanhvien,
                tv.ngaythamgia,
                vdv.mavandongvien,
                vdv.chieucao,
                vdv.cannang,
                vdv.vitri,
                vdv.trangthaidaugiai,
                TRIM(CONCAT(COALESCE(nd.hodem, ''), ' ', COALESCE(nd.ten, ''))) AS hoten,
                nd.avatar
             FROM Thanhviendoibong tv
             JOIN Vandongvien vdv ON vdv.idvandongvien = tv.idvandongvien
             JOIN Nguoidung nd ON nd.idnguoidung = vdv.idnguoidung
             WHERE tv.iddoibong = :team_id
               AND tv.trangthai = 'DANG_THAM_GIA'
               AND vdv.trangthaidaugiai IN ('DU_DIEU_KIEN', 'CHO_XAC_NHAN', 'DANG_NGHI_PHEP')
             ORDER BY
                CASE tv.vaitro
                    WHEN 'DOI_TRUONG' THEN 1
                    WHEN 'THANH_VIEN' THEN 2
                    ELSE 3
                END,
                nd.ten,
                nd.hodem"
        );
        $statement->execute(['team_id' => $teamId]);

        return $statement->fetchAll();
    }

    public function clubTournamentsForSpectator(int $teamId): array
    {
        $statement = $this->db()->prepare(
            "SELECT
                dk.iddangky,
                dk.idgiaidau,
                dk.iddoibong,
                dk.ngaydangky,
                dk.trangthai AS trangthaidangky,
                gd.tengiaidau,
                gd.mota,
                gd.thoigianbatdau,
                gd.thoigianketthuc,
                gd.ghichu_diadiem AS diadiem,
                gd.quymo,
                gd.hinhanh,
                gd.trangthai AS trangthaigiaidau,
                gd.trangthaidangky AS trangthaidangkygiaidau
             FROM Dangkygiaidau dk
             JOIN Giaidau gd ON gd.idgiaidau = dk.idgiaidau
             WHERE dk.iddoibong = :team_id
               AND dk.trangthai = 'DA_DUYET'
               AND gd.trangthai IN ('DA_CONG_BO', 'DANG_DIEN_RA', 'DA_KET_THUC')
             ORDER BY gd.thoigianbatdau DESC, gd.idgiaidau DESC"
        );
        $statement->execute(['team_id' => $teamId]);

        return $statement->fetchAll();
    }

    public function lineupsForTournamentTeam(int $tournamentId, int $teamId): array
    {
        $statement = $this->db()->prepare(
            "SELECT
                dh.iddoihinh,
                dh.iddoibong,
                dh.idgiaidau,
                dh.tendoihinh,
                dh.gioitinh,
                dh.la_doihinh_chinh,
                dh.trangthai,
                dh.ngaytao,
                dh.ngaycapnhat
             FROM Doihinh dh
             WHERE dh.idgiaidau = :tournament_id
               AND dh.iddoibong = :team_id
             ORDER BY dh.ngaytao DESC, dh.iddoihinh DESC"
        );

        $statement->execute([
            'tournament_id' => $tournamentId,
            'team_id' => $teamId,
        ]);

        return $statement->fetchAll();
    }

    public function lineupsForTeam(int $teamId, ?int $tournamentId = null): array
    {
        $sql = "SELECT
                dh.iddoihinh,
                dh.iddoibong,
                dh.idgiaidau,
                dh.tendoihinh,
                dh.gioitinh,
                dh.la_doihinh_chinh,
                dh.trangthai,
                dh.ngaytao,
                dh.ngaycapnhat,
                gd.tengiaidau
             FROM Doihinh dh
             LEFT JOIN Giaidau gd ON gd.idgiaidau = dh.idgiaidau
             WHERE dh.iddoibong = :team_id";
        $bindings = ['team_id' => $teamId];

        if ($tournamentId !== null) {
            $sql .= ' AND dh.idgiaidau = :tournament_id';
            $bindings['tournament_id'] = $tournamentId;
        }

        $statement = $this->db()->prepare($sql . ' ORDER BY dh.ngaytao DESC, dh.iddoihinh DESC');
        $statement->execute($bindings);

        return $statement->fetchAll();
    }

    public function lineupsForCoach(int $coachId, ?int $teamId = null, ?int $tournamentId = null): array
    {
        $sql = "SELECT
                dh.iddoihinh,
                dh.iddoibong,
                dh.idgiaidau,
                dh.tendoihinh,
                dh.gioitinh,
                dh.la_doihinh_chinh,
                dh.trangthai,
                dh.ngaytao,
                dh.ngaycapnhat,
                db.tendoibong,
                gd.tengiaidau
             FROM Doihinh dh
             JOIN Doibong db ON db.iddoibong = dh.iddoibong
             LEFT JOIN Giaidau gd ON gd.idgiaidau = dh.idgiaidau
             WHERE db.idhuanluyenvien = :coach_id";
        $bindings = ['coach_id' => $coachId];

        if ($teamId !== null) {
            $sql .= ' AND dh.iddoibong = :team_id';
            $bindings['team_id'] = $teamId;
        }

        if ($tournamentId !== null) {
            $sql .= ' AND dh.idgiaidau = :tournament_id';
            $bindings['tournament_id'] = $tournamentId;
        }

        $statement = $this->db()->prepare($sql . ' ORDER BY dh.ngaytao DESC, dh.iddoihinh DESC');
        $statement->execute($bindings);

        return $statement->fetchAll();
    }

    public function lineupDetailsForTournamentTeam(int $tournamentId, int $teamId): array
    {
        $statement = $this->db()->prepare(
            "SELECT
                ctdh.idchitietdoihinh,
                ctdh.iddoihinh,
                ctdh.idvandongvien,
                ctdh.vitri,
                ctdh.sothutu,
                ctdh.ghichu,
                vdv.mavandongvien,
                nd.gioitinh,
                TRIM(CONCAT(COALESCE(nd.hodem, ''), ' ', COALESCE(nd.ten, ''))) AS hoten
             FROM Chitietdoihinh ctdh
             JOIN Doihinh dh ON dh.iddoihinh = ctdh.iddoihinh
             JOIN Vandongvien vdv ON vdv.idvandongvien = ctdh.idvandongvien
             JOIN Nguoidung nd ON nd.idnguoidung = vdv.idnguoidung
             WHERE dh.idgiaidau = :tournament_id
               AND dh.iddoibong = :team_id
             ORDER BY dh.iddoihinh, ctdh.sothutu, ctdh.idchitietdoihinh"
        );

        $statement->execute([
            'tournament_id' => $tournamentId,
            'team_id' => $teamId,
        ]);

        return $statement->fetchAll();
    }

    public function lineupDetailsForTeam(int $teamId, ?int $tournamentId = null): array
    {
        $sql = "SELECT
                ctdh.idchitietdoihinh,
                ctdh.iddoihinh,
                ctdh.idvandongvien,
                ctdh.vitri,
                ctdh.sothutu,
                ctdh.ghichu,
                vdv.mavandongvien,
                nd.gioitinh,
                TRIM(CONCAT(COALESCE(nd.hodem, ''), ' ', COALESCE(nd.ten, ''))) AS hoten
             FROM Chitietdoihinh ctdh
             JOIN Doihinh dh ON dh.iddoihinh = ctdh.iddoihinh
             JOIN Vandongvien vdv ON vdv.idvandongvien = ctdh.idvandongvien
             JOIN Nguoidung nd ON nd.idnguoidung = vdv.idnguoidung
             WHERE dh.iddoibong = :team_id";
        $bindings = ['team_id' => $teamId];

        if ($tournamentId !== null) {
            $sql .= ' AND dh.idgiaidau = :tournament_id';
            $bindings['tournament_id'] = $tournamentId;
        }

        $statement = $this->db()->prepare($sql . ' ORDER BY dh.iddoihinh, ctdh.sothutu, ctdh.idchitietdoihinh');
        $statement->execute($bindings);

        return $statement->fetchAll();
    }

    public function lineupDetailsForCoach(int $coachId, ?int $teamId = null, ?int $tournamentId = null): array
    {
        $sql = "SELECT
                ctdh.idchitietdoihinh,
                ctdh.iddoihinh,
                ctdh.idvandongvien,
                ctdh.vitri,
                ctdh.sothutu,
                ctdh.ghichu,
                dh.iddoibong,
                dh.idgiaidau,
                vdv.mavandongvien,
                nd.gioitinh,
                TRIM(CONCAT(COALESCE(nd.hodem, ''), ' ', COALESCE(nd.ten, ''))) AS hoten
             FROM Chitietdoihinh ctdh
             JOIN Doihinh dh ON dh.iddoihinh = ctdh.iddoihinh
             JOIN Doibong db ON db.iddoibong = dh.iddoibong
             JOIN Vandongvien vdv ON vdv.idvandongvien = ctdh.idvandongvien
             JOIN Nguoidung nd ON nd.idnguoidung = vdv.idnguoidung
             WHERE db.idhuanluyenvien = :coach_id";
        $bindings = ['coach_id' => $coachId];

        if ($teamId !== null) {
            $sql .= ' AND dh.iddoibong = :team_id';
            $bindings['team_id'] = $teamId;
        }

        if ($tournamentId !== null) {
            $sql .= ' AND dh.idgiaidau = :tournament_id';
            $bindings['tournament_id'] = $tournamentId;
        }

        $statement = $this->db()->prepare($sql . ' ORDER BY dh.iddoihinh, ctdh.sothutu, ctdh.idchitietdoihinh');
        $statement->execute($bindings);

        return $statement->fetchAll();
    }

    public function statsForTournamentTeam(int $tournamentId, int $teamId): ?array
    {
        return $this->first(
            "SELECT
                idthongkedoi,
                idgiaidau,
                iddoibong,
                sotran,
                sotranthang,
                sotranthua,
                sosetthang,
                sosetthua,
                diem
             FROM Thongkedoi
             WHERE idgiaidau = :tournament_id
               AND iddoibong = :team_id
             LIMIT 1",
            [
                'tournament_id' => $tournamentId,
                'team_id' => $teamId,
            ]
        );
    }

    public function matchesForTournamentTeam(int $tournamentId, int $teamId): array
    {
        $statement = $this->db()->prepare(
            "SELECT
                td.idtrandau,
                td.idgiaidau,
                td.idbangdau,
                td.iddoibong1,
                td.iddoibong2,
                td.idsandau,
                td.thoigianbatdau,
                td.thoigianketthuc,
                vd.tenvongdau AS vongdau,
                td.trangthai,
                d1.tendoibong AS doi1,
                d2.tendoibong AS doi2,
                sd.tensandau,
                vt.diachi AS sandau_diachi
             FROM Trandau td
             JOIN Doibong d1 ON d1.iddoibong = td.iddoibong1
             JOIN Doibong d2 ON d2.iddoibong = td.iddoibong2
             LEFT JOIN Vongdau vd ON vd.idvongdau = td.idvongdau
             LEFT JOIN Sandau sd ON sd.idsandau = td.idsandau
             LEFT JOIN Vitrithidau vt ON vt.idvitrithidau = sd.idvitrithidau
             WHERE td.idgiaidau = :tournament_id
               AND (td.iddoibong1 = :team_id_one OR td.iddoibong2 = :team_id_two)
             ORDER BY td.thoigianbatdau, td.idtrandau"
        );

        $statement->execute([
            'tournament_id' => $tournamentId,
            'team_id_one' => $teamId,
            'team_id_two' => $teamId,
        ]);

        return $statement->fetchAll();
    }

    public function hasActiveMatches(int $tournamentId, int $teamId): bool
    {
        return $this->first(
            "SELECT 1
             FROM Trandau
             WHERE idgiaidau = :tournament_id
               AND (iddoibong1 = :team_id_one OR iddoibong2 = :team_id_two)
               AND trangthai <> 'DA_HUY'
             LIMIT 1",
            [
                'tournament_id' => $tournamentId,
                'team_id_one' => $teamId,
                'team_id_two' => $teamId,
            ]
        ) !== null;
    }

    public function cancelTournamentParticipation(
        int $registrationId,
        string $reason,
        int $actorAccountId,
        ?string $ipAddress,
        string $logNote
    ): void {
        $db = $this->db();

        try {
            $db->beginTransaction();

            $statement = $db->prepare(
                "UPDATE Dangkygiaidau
                 SET trangthai = 'DA_HUY',
                     lydotuchoi = :reason
                 WHERE iddangky = :registration_id
                   AND trangthai = 'DA_DUYET'"
            );

            $statement->execute([
                'reason' => $reason,
                'registration_id' => $registrationId,
            ]);

            if ($statement->rowCount() !== 1) {
                throw new \RuntimeException('PARTICIPATION_NOT_CANCELLED');
            }

            $this->recordStatusHistory('DANG_KY_GIAI', $registrationId, 'DA_DUYET', 'DA_HUY', $reason, $actorAccountId);
            $this->recordSystemLog($actorAccountId, 'Huy tham gia giai dau', 'Dangkygiaidau', $registrationId, $ipAddress, $logNote);

            $db->commit();
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    public function updateForCoach(
        int $teamId,
        int $coachId,
        array $changes,
        string $oldStatus,
        ?string $newStatus,
        int $actorAccountId,
        ?string $ipAddress,
        string $logNote
    ): void {
        $db = $this->db();
        $sets = [];
        $bindings = [
            'team_id' => $teamId,
            'coach_id' => $coachId,
        ];

        foreach ($changes as $field => $value) {
            $sets[] = "{$field} = :{$field}";
            $bindings[$field] = $value;
        }

        $sets[] = 'ngaycapnhat = CURRENT_TIMESTAMP';

        try {
            $db->beginTransaction();

            $statement = $db->prepare(
                'UPDATE Doibong SET ' . implode(', ', $sets) . ' WHERE iddoibong = :team_id AND idhuanluyenvien = :coach_id'
            );
            $statement->execute($bindings);

            if ($statement->rowCount() !== 1) {
                throw new \RuntimeException('TEAM_NOT_UPDATED');
            }

            if ($newStatus !== null && $newStatus !== $oldStatus) {
                $this->recordStatusHistory('DOI_BONG', $teamId, $oldStatus, $newStatus, 'HLV cap nhat trang thai doi bong', $actorAccountId);
            }

            $this->recordSystemLog($actorAccountId, 'Cap nhat doi bong', 'Doibong', $teamId, $ipAddress, $logNote);

            $db->commit();
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    public function athleteForCoachScope(int $coachId, string $athleteIdentifier): ?array
    {
        $athleteIdentifier = trim($athleteIdentifier);
        $where = ctype_digit($athleteIdentifier)
            ? 'vdv.idvandongvien = :athlete_id'
            : 'vdv.mavandongvien = :athlete_code';

        $bindings = ctype_digit($athleteIdentifier)
            ? ['athlete_id' => (int) $athleteIdentifier]
            : ['athlete_code' => $athleteIdentifier];

        $bindings['coach_id_membership'] = $coachId;

        return $this->first(
            "SELECT
                vdv.idvandongvien,
                vdv.idnguoidung,
                vdv.mavandongvien,
                vdv.chieucao,
                vdv.cannang,
                vdv.vitri,
                vdv.trangthaidaugiai,
                nd.hodem,
                nd.ten,
                TRIM(CONCAT(COALESCE(nd.hodem, ''), ' ', COALESCE(nd.ten, ''))) AS hoten,
                tk.username,
                tk.email,
                tk.sodienthoai
             FROM Vandongvien vdv
             JOIN Nguoidung nd ON nd.idnguoidung = vdv.idnguoidung
             JOIN Taikhoan tk ON tk.idtaikhoan = nd.idtaikhoan
             WHERE {$where}
               AND (
                    EXISTS (
                        SELECT 1
                        FROM Thanhviendoibong tv
                        JOIN Doibong db ON db.iddoibong = tv.iddoibong
                        WHERE tv.idvandongvien = vdv.idvandongvien
                          AND db.idhuanluyenvien = :coach_id_membership
                    )
                    OR NOT EXISTS (
                        SELECT 1
                        FROM Thanhviendoibong tv_any
                        WHERE tv_any.idvandongvien = vdv.idvandongvien
                          AND tv_any.trangthai IN ('CHO_XAC_NHAN','DANG_THAM_GIA')
                    )
               )
             LIMIT 1",
            $bindings
        );
    }

    public function memberForCoach(int $coachId, int $memberId): ?array
    {
        return $this->first(
            "SELECT
                tv.idthanhvien,
                tv.iddoibong,
                tv.idvandongvien,
                tv.vaitro,
                tv.trangthai,
                tv.ngaythamgia,
                tv.ngayroi,
                db.tendoibong,
                db.idhuanluyenvien,
                vdv.mavandongvien,
                vdv.trangthaidaugiai,
                TRIM(CONCAT(COALESCE(nd.hodem, ''), ' ', COALESCE(nd.ten, ''))) AS hoten
             FROM Thanhviendoibong tv
             JOIN Doibong db ON db.iddoibong = tv.iddoibong
             JOIN Vandongvien vdv ON vdv.idvandongvien = tv.idvandongvien
             JOIN Nguoidung nd ON nd.idnguoidung = vdv.idnguoidung
             WHERE tv.idthanhvien = :member_id
               AND db.idhuanluyenvien = :coach_id
             LIMIT 1",
            [
                'member_id' => $memberId,
                'coach_id' => $coachId,
            ]
        );
    }

    public function activeMembershipForAthlete(int $athleteId): ?array
    {
        return $this->first(
            "SELECT tv.idthanhvien, tv.iddoibong, tv.idvandongvien, tv.trangthai, db.idhuanluyenvien, db.tendoibong
             FROM Thanhviendoibong tv
             JOIN Doibong db ON db.iddoibong = tv.iddoibong
             WHERE tv.idvandongvien = :athlete_id
               AND tv.trangthai IN ('CHO_XAC_NHAN','DANG_THAM_GIA')
             ORDER BY tv.idthanhvien DESC
             LIMIT 1",
            ['athlete_id' => $athleteId]
        );
    }

    public function membershipForTeamAthlete(int $teamId, int $athleteId): ?array
    {
        return $this->first(
            "SELECT
                tv.idthanhvien,
                tv.iddoibong,
                tv.idvandongvien,
                tv.vaitro,
                tv.trangthai,
                tv.ngaythamgia,
                tv.ngayroi
             FROM Thanhviendoibong tv
             WHERE tv.iddoibong = :team_id
               AND tv.idvandongvien = :athlete_id
             LIMIT 1",
            [
                'team_id' => $teamId,
                'athlete_id' => $athleteId,
            ]
        );
    }

    public function addMember(
        int $teamId,
        int $coachId,
        int $athleteId,
        string $role,
        string $joinDate,
        int $actorAccountId,
        ?string $ipAddress,
        string $logNote
    ): int {
        $db = $this->db();

        try {
            $db->beginTransaction();

            $statement = $db->prepare(
                "INSERT INTO Thanhviendoibong (iddoibong, idvandongvien, vaitro, trangthai, ngaythamgia)
                 SELECT :team_id, :athlete_id, :role, 'DANG_THAM_GIA', :join_date
                 FROM Doibong db
                 WHERE db.iddoibong = :team_id_check
                   AND db.idhuanluyenvien = :coach_id"
            );
            $statement->execute([
                'team_id' => $teamId,
                'athlete_id' => $athleteId,
                'role' => $role,
                'join_date' => $joinDate,
                'team_id_check' => $teamId,
                'coach_id' => $coachId,
            ]);

            if ($statement->rowCount() !== 1) {
                throw new \RuntimeException('MEMBER_NOT_ADDED');
            }

            $memberId = (int) $db->lastInsertId();
            $this->recordMemberHistory($memberId, 'THEM_THANH_VIEN', 'HLV them thanh vien vao doi bong', $actorAccountId);
            $this->recordSystemLog($actorAccountId, 'Them thanh vien doi bong', 'Thanhviendoibong', $memberId, $ipAddress, $logNote);

            $db->commit();

            return $memberId;
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    public function removeMember(
        int $memberId,
        int $coachId,
        string $reason,
        int $actorAccountId,
        ?string $ipAddress,
        string $logNote
    ): void {
        $db = $this->db();

        try {
            $db->beginTransaction();

            $statement = $db->prepare(
                "UPDATE Thanhviendoibong tv
                 JOIN Doibong db ON db.iddoibong = tv.iddoibong
                 SET tv.trangthai = 'BI_LOAI',
                     tv.ngayroi = CURRENT_DATE
                 WHERE tv.idthanhvien = :member_id
                   AND db.idhuanluyenvien = :coach_id
                   AND tv.trangthai IN ('CHO_XAC_NHAN','DANG_THAM_GIA')"
            );
            $statement->execute([
                'member_id' => $memberId,
                'coach_id' => $coachId,
            ]);

            if ($statement->rowCount() !== 1) {
                throw new \RuntimeException('MEMBER_NOT_REMOVED');
            }

            $this->recordMemberHistory($memberId, 'XOA_THANH_VIEN', $reason, $actorAccountId);
            $this->recordSystemLog($actorAccountId, 'Xoa thanh vien doi bong', 'Thanhviendoibong', $memberId, $ipAddress, $logNote);

            $db->commit();
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    public function transferMember(
        int $memberId,
        int $coachId,
        int $targetTeamId,
        string $role,
        string $reason,
        int $actorAccountId,
        ?string $ipAddress,
        string $logNote
    ): int {
        $db = $this->db();

        try {
            $db->beginTransaction();

            $member = $this->memberForCoach($coachId, $memberId);
            $targetTeam = $this->findForCoach($coachId, $targetTeamId);

            if ($member === null || $targetTeam === null || (int) $member['iddoibong'] === $targetTeamId) {
                throw new \RuntimeException('MEMBER_NOT_TRANSFERRED');
            }

            $statement = $db->prepare(
                "UPDATE Thanhviendoibong
                 SET trangthai = 'DA_ROI_DOI',
                     ngayroi = CURRENT_DATE
                 WHERE idthanhvien = :member_id
                   AND trangthai IN ('CHO_XAC_NHAN','DANG_THAM_GIA')"
            );
            $statement->execute(['member_id' => $memberId]);

            if ($statement->rowCount() !== 1) {
                throw new \RuntimeException('MEMBER_NOT_TRANSFERRED');
            }

            $statement = $db->prepare(
                "INSERT INTO Thanhviendoibong (iddoibong, idvandongvien, vaitro, trangthai, ngaythamgia)
                 VALUES (:team_id, :athlete_id, :role, 'DANG_THAM_GIA', CURRENT_DATE)"
            );
            $statement->execute([
                'team_id' => $targetTeamId,
                'athlete_id' => (int) $member['idvandongvien'],
                'role' => $role,
            ]);

            $newMemberId = (int) $db->lastInsertId();

            $this->recordMemberHistory($memberId, 'CHUYEN_DOI_THANH_VIEN', $reason, $actorAccountId);
            $this->recordMemberHistory($newMemberId, 'CHUYEN_DOI_THANH_VIEN', $reason, $actorAccountId);
            $this->recordSystemLog($actorAccountId, 'Chuyen doi thanh vien doi bong', 'Thanhviendoibong', $newMemberId, $ipAddress, $logNote);

            $db->commit();

            return $newMemberId;
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    public function teamRegisteredForTournament(int $coachId, int $teamId, int $tournamentId): ?array
    {
        return $this->first(
            "SELECT
                dk.iddangky,
                dk.idgiaidau,
                dk.iddoibong,
                dk.idhuanluyenvien,
                dk.trangthai AS trangthaidangky,
                gd.tengiaidau,
                gd.trangthai AS trangthaigiaidau,
                db.tendoibong,
                db.trangthai AS trangthaidoibong
             FROM Dangkygiaidau dk
             JOIN Giaidau gd ON gd.idgiaidau = dk.idgiaidau
             JOIN Doibong db ON db.iddoibong = dk.iddoibong
             WHERE dk.idhuanluyenvien = :coach_id
               AND dk.iddoibong = :team_id
               AND dk.idgiaidau = :tournament_id
               AND dk.trangthai = 'DA_DUYET'
             LIMIT 1",
            [
                'coach_id' => $coachId,
                'team_id' => $teamId,
                'tournament_id' => $tournamentId,
            ]
        );
    }

    public function lineupForCoach(int $coachId, int $lineupId): ?array
    {
        return $this->first(
            "SELECT
                dh.iddoihinh,
                dh.iddoibong,
                dh.idgiaidau,
                dh.tendoihinh,
                dh.gioitinh,
                dh.la_doihinh_chinh,
                dh.trangthai,
                dh.ngaytao,
                dh.ngaycapnhat,
                db.tendoibong,
                gd.tengiaidau
             FROM Doihinh dh
             JOIN Doibong db ON db.iddoibong = dh.iddoibong
             LEFT JOIN Giaidau gd ON gd.idgiaidau = dh.idgiaidau
             WHERE dh.iddoihinh = :lineup_id
               AND db.idhuanluyenvien = :coach_id
             LIMIT 1",
            [
                'lineup_id' => $lineupId,
                'coach_id' => $coachId,
            ]
        );
    }

    public function lineupDetails(int $lineupId): array
    {
        $statement = $this->db()->prepare(
            "SELECT
                ctdh.idchitietdoihinh,
                ctdh.iddoihinh,
                ctdh.idvandongvien,
                ctdh.vitri,
                ctdh.sothutu,
                ctdh.ghichu,
                vdv.mavandongvien,
                nd.gioitinh,
                TRIM(CONCAT(COALESCE(nd.hodem, ''), ' ', COALESCE(nd.ten, ''))) AS hoten
             FROM Chitietdoihinh ctdh
             JOIN Vandongvien vdv ON vdv.idvandongvien = ctdh.idvandongvien
             JOIN Nguoidung nd ON nd.idnguoidung = vdv.idnguoidung
             WHERE ctdh.iddoihinh = :lineup_id
             ORDER BY ctdh.sothutu, ctdh.idchitietdoihinh"
        );

        $statement->execute(['lineup_id' => $lineupId]);

        return $statement->fetchAll();
    }

    public function lineupNameExists(int $teamId, string $name, ?int $excludeLineupId = null, ?int $tournamentId = null): bool
    {
        $sql = "SELECT 1
             FROM Doihinh
             WHERE iddoibong = :team_id
               AND tendoihinh = :name";
        $bindings = [
            'team_id' => $teamId,
            'name' => $name,
        ];

        if ($tournamentId !== null) {
            $sql .= ' AND idgiaidau = :tournament_id';
            $bindings['tournament_id'] = $tournamentId;
        }

        if ($excludeLineupId !== null) {
            $sql .= ' AND iddoihinh <> :exclude_lineup_id';
            $bindings['exclude_lineup_id'] = $excludeLineupId;
        }

        return $this->first($sql . ' LIMIT 1', $bindings) !== null;
    }

    public function athleteIsActiveMember(int $teamId, int $athleteId): bool
    {
        return $this->first(
            "SELECT 1
             FROM Thanhviendoibong
             WHERE iddoibong = :team_id
               AND idvandongvien = :athlete_id
               AND trangthai = 'DANG_THAM_GIA'
             LIMIT 1",
            [
                'team_id' => $teamId,
                'athlete_id' => $athleteId,
            ]
        ) !== null;
    }

    public function athleteIsActiveMemberWithGender(int $teamId, int $athleteId, string $gender): bool
    {
        return $this->first(
            "SELECT 1
             FROM Thanhviendoibong tv
             JOIN Vandongvien vdv ON vdv.idvandongvien = tv.idvandongvien
             JOIN Nguoidung nd ON nd.idnguoidung = vdv.idnguoidung
             WHERE tv.iddoibong = :team_id
               AND tv.idvandongvien = :athlete_id
               AND tv.trangthai = 'DANG_THAM_GIA'
               AND nd.gioitinh = :gender
             LIMIT 1",
            [
                'team_id' => $teamId,
                'athlete_id' => $athleteId,
                'gender' => $gender,
            ]
        ) !== null;
    }

    public function createLineup(
        int $teamId,
        ?int $tournamentId,
        array $lineup,
        array $details,
        int $actorAccountId,
        ?string $ipAddress,
        string $logNote
    ): int {
        $db = $this->db();

        try {
            $db->beginTransaction();

            $statement = $db->prepare(
                "INSERT INTO Doihinh (iddoibong, idgiaidau, tendoihinh, gioitinh, la_doihinh_chinh, trangthai)
                 VALUES (:team_id, :tournament_id, :name, :gender, :is_main, :status)"
            );
            $statement->execute([
                'team_id' => $teamId,
                'tournament_id' => $tournamentId,
                'name' => $lineup['tendoihinh'],
                'gender' => $lineup['gioitinh'] ?? 'NAM',
                'is_main' => (int) ($lineup['la_doihinh_chinh'] ?? 0),
                'status' => $lineup['trangthai'],
            ]);

            $lineupId = (int) $db->lastInsertId();
            if ((int) ($lineup['la_doihinh_chinh'] ?? 0) === 1) {
                $this->unsetOtherMainLineups($teamId, $lineupId, (string) ($lineup['gioitinh'] ?? 'NAM'));
            }

            $this->insertLineupDetails($lineupId, $details);
            $this->recordSystemLog($actorAccountId, 'Tao doi hinh', 'Doihinh', $lineupId, $ipAddress, $logNote);

            $db->commit();

            return $lineupId;
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    public function updateLineup(
        int $lineupId,
        array $changes,
        ?array $details,
        int $actorAccountId,
        ?string $ipAddress,
        string $logNote
    ): void {
        $db = $this->db();
        $sets = [];
        $bindings = ['lineup_id' => $lineupId];

        foreach ($changes as $field => $value) {
            $sets[] = "{$field} = :{$field}";
            $bindings[$field] = $value;
        }

        $sets[] = 'ngaycapnhat = CURRENT_TIMESTAMP';

        try {
            $db->beginTransaction();

            $current = $this->first(
                'SELECT iddoibong, gioitinh FROM Doihinh WHERE iddoihinh = :lineup_id LIMIT 1',
                ['lineup_id' => $lineupId]
            );

            if ($current === null) {
                throw new \RuntimeException('LINEUP_NOT_UPDATED');
            }

            if ($changes !== [] || $details !== null) {
                $statement = $db->prepare(
                    'UPDATE Doihinh SET ' . implode(', ', $sets) . ' WHERE iddoihinh = :lineup_id'
                );
                $statement->execute($bindings);

                if ($statement->rowCount() < 1 && $this->first('SELECT 1 FROM Doihinh WHERE iddoihinh = :lineup_id LIMIT 1', ['lineup_id' => $lineupId]) === null) {
                    throw new \RuntimeException('LINEUP_NOT_UPDATED');
                }
            }

            if ((int) ($changes['la_doihinh_chinh'] ?? 0) === 1) {
                $this->unsetOtherMainLineups(
                    (int) $current['iddoibong'],
                    $lineupId,
                    (string) ($changes['gioitinh'] ?? $current['gioitinh'] ?? 'NAM')
                );
            }

            if ($details !== null) {
                $statement = $db->prepare('DELETE FROM Chitietdoihinh WHERE iddoihinh = :lineup_id');
                $statement->execute(['lineup_id' => $lineupId]);
                $this->insertLineupDetails($lineupId, $details);
            }

            $this->recordSystemLog($actorAccountId, 'Cap nhat doi hinh', 'Doihinh', $lineupId, $ipAddress, $logNote);

            $db->commit();
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    private function unsetOtherMainLineups(int $teamId, int $lineupId, string $gender): void
    {
        $statement = $this->db()->prepare(
            "UPDATE Doihinh
             SET la_doihinh_chinh = 0,
                 ngaycapnhat = CURRENT_TIMESTAMP
             WHERE iddoibong = :team_id
               AND iddoihinh <> :lineup_id
               AND gioitinh = :gender
               AND la_doihinh_chinh = 1"
        );
        $statement->execute([
            'team_id' => $teamId,
            'lineup_id' => $lineupId,
            'gender' => $gender,
        ]);
    }

    public function scheduleForCoachTeam(int $coachId, int $teamId, array $filters = []): array
    {
        $where = [
            'db.idhuanluyenvien = :coach_id',
            '(td.iddoibong1 = :team_id_one OR td.iddoibong2 = :team_id_two)',
        ];
        $bindings = [
            'coach_id' => $coachId,
            'team_id_one' => $teamId,
            'team_id_two' => $teamId,
        ];

        if (($filters['tournament_id'] ?? '') !== '') {
            $where[] = 'td.idgiaidau = :tournament_id';
            $bindings['tournament_id'] = (int) $filters['tournament_id'];
        }

        if (($filters['status'] ?? '') !== '') {
            $where[] = 'td.trangthai = :status';
            $bindings['status'] = $filters['status'];
        }

        if (($filters['from'] ?? '') !== '') {
            $where[] = 'td.thoigianbatdau >= :from_date';
            $bindings['from_date'] = $filters['from'] . ' 00:00:00';
        }

        if (($filters['to'] ?? '') !== '') {
            $where[] = 'td.thoigianbatdau <= :to_date';
            $bindings['to_date'] = $filters['to'] . ' 23:59:59';
        }

        if (($filters['q'] ?? '') !== '') {
            $where[] = "(gd.tengiaidau LIKE :keyword
                OR d1.tendoibong LIKE :keyword
                OR d2.tendoibong LIKE :keyword
                OR sd.tensandau LIKE :keyword
                OR vd.tenvongdau LIKE :keyword
                OR bd.tenbang LIKE :keyword)";
            $bindings['keyword'] = '%' . $filters['q'] . '%';
        }

        $statement = $this->db()->prepare(
            "SELECT
                td.idtrandau,
                td.idgiaidau,
                gd.tengiaidau,
                td.idbangdau,
                bd.tenbang,
                td.iddoibong1,
                d1.tendoibong AS doi1,
                td.iddoibong2,
                d2.tendoibong AS doi2,
                td.idsandau,
                sd.tensandau,
                vt.diachi AS sandau_diachi,
                td.thoigianbatdau,
                td.thoigianketthuc,
                vd.tenvongdau AS vongdau,
                td.trangthai,
                CASE WHEN td.iddoibong1 = :team_id_side THEN 'DOI_1' ELSE 'DOI_2' END AS phia_doi_bong
             FROM Trandau td
             JOIN Giaidau gd ON gd.idgiaidau = td.idgiaidau
             JOIN Doibong d1 ON d1.iddoibong = td.iddoibong1
             JOIN Doibong d2 ON d2.iddoibong = td.iddoibong2
             JOIN Doibong db ON db.iddoibong = :team_id_owner
             LEFT JOIN Vongdau vd ON vd.idvongdau = td.idvongdau
             LEFT JOIN Sandau sd ON sd.idsandau = td.idsandau
             LEFT JOIN Vitrithidau vt ON vt.idvitrithidau = sd.idvitrithidau
             LEFT JOIN Bangdau bd ON bd.idbangdau = td.idbangdau
             WHERE " . implode(' AND ', $where) . "
             ORDER BY td.thoigianbatdau, td.idtrandau"
        );

        $bindings['team_id_side'] = $teamId;
        $bindings['team_id_owner'] = $teamId;
        $statement->execute($bindings);

        return $statement->fetchAll();
    }

    public function recordCoachSystemLog(
        int $accountId,
        string $action,
        string $targetTable,
        ?int $targetId,
        ?string $ipAddress,
        ?string $note
    ): void {
        $this->recordSystemLog($accountId, $action, $targetTable, $targetId, $ipAddress, $note);
    }

    private function insertLineupDetails(int $lineupId, array $details): void
    {
        $statement = $this->db()->prepare(
            "INSERT INTO Chitietdoihinh (iddoihinh, idvandongvien, vitri, sothutu, ghichu)
             VALUES (:lineup_id, :athlete_id, :position, :order_number, :note)"
        );

        foreach ($details as $detail) {
            $statement->execute([
                'lineup_id' => $lineupId,
                'athlete_id' => $detail['idvandongvien'],
                'position' => $detail['vitri'],
                'order_number' => $detail['sothutu'],
                'note' => $detail['ghichu'],
            ]);
        }
    }

    private function recordMemberHistory(int $memberId, string $action, ?string $reason, ?int $actorId): void
    {
        $statement = $this->db()->prepare(
            "INSERT INTO Lichsuthanhviendoibong (idthanhvien, hanhdong, ghichu, idnguoithuchien)
             VALUES (:member_id, :action, :reason, :actor_id)"
        );

        $statement->execute([
            'member_id' => $memberId,
            'action' => $action,
            'reason' => $reason,
            'actor_id' => $actorId,
        ]);
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
