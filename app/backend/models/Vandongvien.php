<?php

declare(strict_types=1);

namespace App\Backend\Models;

use App\Backend\Core\Model;
use Throwable;

final class Vandongvien extends Model
{
    public function listForOrganizer(int $organizerId, array $filters = []): array
    {
        [$sql, $bindings] = $this->baseAthleteQuery($organizerId, $filters);
        $sql .= ' ORDER BY vdv.idvandongvien DESC';

        $statement = $this->db()->prepare($sql);
        $statement->execute($bindings);

        return $statement->fetchAll();
    }

    public function findForOrganizer(int $organizerId, int $athleteId): ?array
    {
        [$sql, $bindings] = $this->baseAthleteQuery($organizerId, []);
        $sql .= ' AND vdv.idvandongvien = :athlete_id LIMIT 1';
        $bindings['athlete_id'] = $athleteId;

        return $this->first($sql, $bindings);
    }

    public function membershipsForOrganizer(int $organizerId, int $athleteId): array
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
                db.tendoibong,
                db.logo AS doibong_logo,
                db.diaphuong AS doibong_diaphuong,
                db.trangthai AS trangthaidoibong,
                dk.iddangky,
                dk.idgiaidau,
                dk.trangthai AS trangthaidangky,
                gd.tengiaidau,
                gd.trangthai AS trangthaigiaidau,
                hlv.idhuanluyenvien,
                TRIM(CONCAT(COALESCE(nd_hlv.hodem, ''), ' ', COALESCE(nd_hlv.ten, ''))) AS huanluyenvien_hoten,
                tk_hlv.username AS huanluyenvien_username
             FROM Thanhviendoibong tv
             JOIN Doibong db ON db.iddoibong = tv.iddoibong
             JOIN Dangkygiaidau dk ON dk.iddoibong = db.iddoibong
             JOIN Giaidau gd ON gd.idgiaidau = dk.idgiaidau
             JOIN Huanluyenvien hlv ON hlv.idhuanluyenvien = db.idhuanluyenvien
             JOIN Nguoidung nd_hlv ON nd_hlv.idnguoidung = hlv.idnguoidung
             JOIN Taikhoan tk_hlv ON tk_hlv.idtaikhoan = nd_hlv.idtaikhoan
             WHERE gd.idbantochuc = :organizer_id
               AND tv.idvandongvien = :athlete_id
             ORDER BY gd.ngaytao DESC, db.tendoibong, tv.idthanhvien"
        );

        $statement->execute([
            'organizer_id' => $organizerId,
            'athlete_id' => $athleteId,
        ]);

        return $statement->fetchAll();
    }

    public function lineupsForOrganizer(int $organizerId, int $athleteId): array
    {
        $statement = $this->db()->prepare(
            "SELECT
                ctdh.idchitietdoihinh,
                ctdh.iddoihinh,
                ctdh.idvandongvien,
                ctdh.vitri,
                ctdh.sothutu,
                ctdh.ghichu,
                dh.tendoihinh,
                dh.trangthai AS trangthaidoihinh,
                dh.iddoibong,
                dh.idgiaidau,
                db.tendoibong,
                gd.tengiaidau
             FROM Chitietdoihinh ctdh
             JOIN Doihinh dh ON dh.iddoihinh = ctdh.iddoihinh
             JOIN Doibong db ON db.iddoibong = dh.iddoibong
             JOIN Giaidau gd ON gd.idgiaidau = dh.idgiaidau
             WHERE gd.idbantochuc = :organizer_id
               AND ctdh.idvandongvien = :athlete_id
             ORDER BY gd.ngaytao DESC, dh.iddoihinh DESC, ctdh.sothutu"
        );

        $statement->execute([
            'organizer_id' => $organizerId,
            'athlete_id' => $athleteId,
        ]);

        return $statement->fetchAll();
    }

    public function statsForOrganizer(int $organizerId, int $athleteId): array
    {
        $statement = $this->db()->prepare(
            "SELECT
                tkcn.idthongkecanhan,
                tkcn.idvandongvien,
                tkcn.idgiaidau,
                tkcn.idtrandau,
                tkcn.sodiem,
                tkcn.solanphatbong,
                tkcn.solanchanbong,
                tkcn.solanghidiem,
                tkcn.ghichu,
                gd.tengiaidau,
                td.vongdau,
                td.thoigianbatdau
             FROM Thongkecanhan tkcn
             JOIN Giaidau gd ON gd.idgiaidau = tkcn.idgiaidau
             JOIN Trandau td ON td.idtrandau = tkcn.idtrandau
             WHERE gd.idbantochuc = :organizer_id
               AND tkcn.idvandongvien = :athlete_id
             ORDER BY td.thoigianbatdau DESC, tkcn.idthongkecanhan DESC"
        );

        $statement->execute([
            'organizer_id' => $organizerId,
            'athlete_id' => $athleteId,
        ]);

        return $statement->fetchAll();
    }

    public function updateCompetitionQualification(
        int $athleteId,
        string $oldStatus,
        string $newStatus,
        ?int $requestId,
        ?string $requestStatus,
        string $reason,
        int $actorAccountId,
        ?string $ipAddress,
        string $systemAction,
        string $logNote
    ): void {
        $db = $this->db();

        try {
            $db->beginTransaction();

            $statement = $db->prepare(
                "UPDATE Vandongvien
                 SET trangthaidaugiai = :new_status
                 WHERE idvandongvien = :athlete_id
                   AND trangthaidaugiai = :old_status"
            );
            $statement->execute([
                'new_status' => $newStatus,
                'athlete_id' => $athleteId,
                'old_status' => $oldStatus,
            ]);

            if ($statement->rowCount() !== 1) {
                throw new \RuntimeException('ATHLETE_QUALIFICATION_NOT_UPDATED');
            }

            if ($requestId !== null && $requestStatus !== null) {
                $statement = $db->prepare(
                    "UPDATE Yeucauxacnhan
                     SET trangthai = :request_status,
                         ngayxuly = CURRENT_TIMESTAMP,
                         ghichu = :reason
                     WHERE idyeucau = :request_id
                       AND trangthai = 'CHO_DUYET'"
                );
                $statement->execute([
                    'request_status' => $requestStatus,
                    'reason' => $reason,
                    'request_id' => $requestId,
                ]);

                if ($statement->rowCount() === 1) {
                    $this->recordStatusHistory('YEU_CAU_XAC_NHAN', $requestId, 'CHO_DUYET', $requestStatus, $reason, $actorAccountId);
                }
            }

            $this->recordSystemLog($actorAccountId, $systemAction, 'Vandongvien', $athleteId, $ipAddress, $logNote);

            $db->commit();
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    private function baseAthleteQuery(int $organizerId, array $filters): array
    {
        $where = ['(team_stats.total_memberships IS NOT NULL OR yc.idyeucau IS NOT NULL)'];
        $bindings = [
            'organizer_request_id' => $organizerId,
            'organizer_team_id' => $organizerId,
        ];

        if (($filters['q'] ?? '') !== '') {
            $where[] = "(vdv.mavandongvien LIKE :keyword
                OR vdv.vitri LIKE :keyword
                OR tk.username LIKE :keyword
                OR tk.email LIKE :keyword
                OR tk.sodienthoai LIKE :keyword
                OR nd.cccd LIKE :keyword
                OR TRIM(CONCAT(COALESCE(nd.hodem, ''), ' ', COALESCE(nd.ten, ''))) LIKE :keyword)";
            $bindings['keyword'] = '%' . $filters['q'] . '%';
        }

        if (($filters['status'] ?? '') !== '') {
            $where[] = 'vdv.trangthaidaugiai = :status';
            $bindings['status'] = $filters['status'];
        }

        if (($filters['account_status'] ?? '') !== '') {
            $where[] = 'tk.trangthai = :account_status';
            $bindings['account_status'] = $filters['account_status'];
        }

        if (($filters['request_status'] ?? '') !== '') {
            $where[] = 'yc.trangthai = :request_status';
            $bindings['request_status'] = $filters['request_status'];
        }

        if (($filters['request_presence'] ?? '') === 'HAS_REQUEST') {
            $where[] = 'yc.idyeucau IS NOT NULL';
        }

        if (($filters['request_presence'] ?? '') === 'NO_REQUEST') {
            $where[] = 'yc.idyeucau IS NULL';
        }

        if (($filters['team_id'] ?? '') !== '') {
            $where[] = "EXISTS (
                SELECT 1
                FROM Thanhviendoibong tv_filter
                JOIN Doibong db_filter ON db_filter.iddoibong = tv_filter.iddoibong
                JOIN Dangkygiaidau dk_filter ON dk_filter.iddoibong = db_filter.iddoibong
                JOIN Giaidau gd_filter ON gd_filter.idgiaidau = dk_filter.idgiaidau
                WHERE gd_filter.idbantochuc = :organizer_team_filter_id
                  AND tv_filter.idvandongvien = vdv.idvandongvien
                  AND tv_filter.iddoibong = :team_id
            )";
            $bindings['organizer_team_filter_id'] = $organizerId;
            $bindings['team_id'] = (int) $filters['team_id'];
        }

        if (($filters['tournament_id'] ?? '') !== '') {
            $where[] = "EXISTS (
                SELECT 1
                FROM Thanhviendoibong tv_tournament_filter
                JOIN Doibong db_tournament_filter ON db_tournament_filter.iddoibong = tv_tournament_filter.iddoibong
                JOIN Dangkygiaidau dk_tournament_filter ON dk_tournament_filter.iddoibong = db_tournament_filter.iddoibong
                JOIN Giaidau gd_tournament_filter ON gd_tournament_filter.idgiaidau = dk_tournament_filter.idgiaidau
                WHERE gd_tournament_filter.idbantochuc = :organizer_tournament_filter_id
                  AND tv_tournament_filter.idvandongvien = vdv.idvandongvien
                  AND gd_tournament_filter.idgiaidau = :tournament_id
            )";
            $bindings['organizer_tournament_filter_id'] = $organizerId;
            $bindings['tournament_id'] = (int) $filters['tournament_id'];
        }

        if (($filters['from'] ?? '') !== '') {
            $where[] = 'COALESCE(yc.ngaygui, nd.ngaytao) >= :from_date';
            $bindings['from_date'] = $filters['from'] . ' 00:00:00';
        }

        if (($filters['to'] ?? '') !== '') {
            $where[] = 'COALESCE(yc.ngaygui, nd.ngaytao) <= :to_date';
            $bindings['to_date'] = $filters['to'] . ' 23:59:59';
        }

        $sql = "SELECT
                vdv.idvandongvien,
                vdv.idnguoidung,
                vdv.mavandongvien,
                vdv.chieucao,
                vdv.cannang,
                vdv.vitri,
                vdv.trangthaidaugiai,
                nd.idtaikhoan,
                nd.hodem,
                nd.ten,
                TRIM(CONCAT(COALESCE(nd.hodem, ''), ' ', COALESCE(nd.ten, ''))) AS hoten,
                nd.gioitinh,
                nd.ngaysinh,
                nd.quequan,
                nd.diachi,
                nd.avatar,
                nd.cccd,
                nd.ngaytao AS nguoidung_ngaytao,
                nd.ngaycapnhat AS nguoidung_ngaycapnhat,
                tk.username,
                tk.email,
                tk.sodienthoai,
                tk.trangthai AS trangthai_taikhoan,
                yc.idyeucau,
                yc.noidung AS yeucau_noidung,
                yc.trangthai AS yeucau_trangthai,
                yc.ngaygui AS yeucau_ngaygui,
                yc.ngayxuly AS yeucau_ngayxuly,
                yc.ghichu AS yeucau_ghichu,
                COALESCE(yc.ngaygui, nd.ngaytao) AS ngaythamchieu,
                COALESCE(team_stats.total_memberships, 0) AS total_memberships,
                COALESCE(team_stats.active_memberships, 0) AS active_memberships,
                COALESCE(team_stats.total_tournaments, 0) AS total_tournaments,
                team_stats.team_names,
                team_stats.tournament_names,
                team_stats.latest_join_date
             FROM Vandongvien vdv
             JOIN Nguoidung nd ON nd.idnguoidung = vdv.idnguoidung
             JOIN Taikhoan tk ON tk.idtaikhoan = nd.idtaikhoan
             LEFT JOIN (
                SELECT
                    idnguoigui,
                    MAX(idyeucau) AS latest_request_id
                FROM Yeucauxacnhan
                WHERE loainguoigui = 'VAN_DONG_VIEN'
                  AND loainguoinhan = 'BAN_TO_CHUC'
                  AND loaixacnhan = 'XAC_NHAN_VDV'
                  AND idnguoinhan = :organizer_request_id
                GROUP BY idnguoigui
             ) latest_yc ON latest_yc.idnguoigui = vdv.idvandongvien
             LEFT JOIN Yeucauxacnhan yc ON yc.idyeucau = latest_yc.latest_request_id
             LEFT JOIN (
                SELECT
                    tv.idvandongvien,
                    COUNT(DISTINCT tv.idthanhvien) AS total_memberships,
                    SUM(CASE WHEN tv.trangthai = 'DANG_THAM_GIA' THEN 1 ELSE 0 END) AS active_memberships,
                    COUNT(DISTINCT gd.idgiaidau) AS total_tournaments,
                    GROUP_CONCAT(DISTINCT db.tendoibong ORDER BY db.tendoibong SEPARATOR ', ') AS team_names,
                    GROUP_CONCAT(DISTINCT gd.tengiaidau ORDER BY gd.tengiaidau SEPARATOR ', ') AS tournament_names,
                    MAX(tv.ngaythamgia) AS latest_join_date
                FROM Thanhviendoibong tv
                JOIN Doibong db ON db.iddoibong = tv.iddoibong
                JOIN Dangkygiaidau dk ON dk.iddoibong = db.iddoibong
                JOIN Giaidau gd ON gd.idgiaidau = dk.idgiaidau
                WHERE gd.idbantochuc = :organizer_team_id
                GROUP BY tv.idvandongvien
             ) team_stats ON team_stats.idvandongvien = vdv.idvandongvien
             WHERE " . implode(' AND ', $where);

        return [$sql, $bindings];
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
