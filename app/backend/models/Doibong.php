<?php

declare(strict_types=1);

namespace App\Backend\Models;

use App\Backend\Core\Model;
use Throwable;

final class Doibong extends Model
{
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

    public function lineupsForTournamentTeam(int $tournamentId, int $teamId): array
    {
        $statement = $this->db()->prepare(
            "SELECT
                dh.iddoihinh,
                dh.iddoibong,
                dh.idgiaidau,
                dh.tendoihinh,
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
                td.vongdau,
                td.trangthai,
                d1.tendoibong AS doi1,
                d2.tendoibong AS doi2,
                sd.tensandau,
                sd.diachi AS sandau_diachi
             FROM Trandau td
             JOIN Doibong d1 ON d1.iddoibong = td.iddoibong1
             JOIN Doibong d2 ON d2.iddoibong = td.iddoibong2
             JOIN Sandau sd ON sd.idsandau = td.idsandau
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
