<?php

declare(strict_types=1);

namespace App\Backend\Models;

use App\Backend\Core\Model;
use Throwable;

final class Lichthidau extends Model
{
    public function scheduleTournaments(int $organizerId, array $filters = []): array
    {
        $where = [
            'gd.idbantochuc = :organizer_id',
            "gd.trangthai = 'DA_CONG_BO'",
            "gd.trangthaidangky = 'DA_DONG'",
        ];
        $bindings = ['organizer_id' => $organizerId];

        if (($filters['q'] ?? '') !== '') {
            $where[] = '(gd.tengiaidau LIKE :keyword OR gd.diadiem LIKE :keyword)';
            $bindings['keyword'] = '%' . $filters['q'] . '%';
        }

        $statement = $this->db()->prepare(
            "SELECT
                gd.idgiaidau,
                gd.tengiaidau,
                gd.thoigianbatdau,
                gd.thoigianketthuc,
                gd.diadiem,
                gd.quymo,
                gd.trangthai,
                gd.trangthaidangky,
                gd.ngaytao,
                gd.ngaycapnhat,
                COALESCE(team_stats.total_teams, 0) AS total_teams,
                COALESCE(group_stats.total_groups, 0) AS total_groups,
                COALESCE(match_stats.total_matches, 0) AS total_matches
             FROM Giaidau gd
             LEFT JOIN (
                SELECT idgiaidau, COUNT(*) AS total_teams
                FROM Dangkygiaidau
                WHERE trangthai = 'DA_DUYET'
                GROUP BY idgiaidau
             ) team_stats ON team_stats.idgiaidau = gd.idgiaidau
             LEFT JOIN (
                SELECT idgiaidau, COUNT(*) AS total_groups
                FROM Bangdau
                WHERE trangthai <> 'DA_XOA'
                GROUP BY idgiaidau
             ) group_stats ON group_stats.idgiaidau = gd.idgiaidau
             LEFT JOIN (
                SELECT idgiaidau, COUNT(*) AS total_matches
                FROM Trandau
                WHERE trangthai <> 'DA_HUY'
                GROUP BY idgiaidau
             ) match_stats ON match_stats.idgiaidau = gd.idgiaidau
             WHERE " . implode(' AND ', $where) . "
             ORDER BY gd.thoigianbatdau DESC, gd.idgiaidau DESC"
        );

        $statement->execute($bindings);

        return $statement->fetchAll();
    }

    public function tournamentForOrganizer(int $organizerId, int $tournamentId): ?array
    {
        return $this->first(
            "SELECT
                gd.idgiaidau,
                gd.tengiaidau,
                gd.mota,
                gd.thoigianbatdau,
                gd.thoigianketthuc,
                gd.diadiem,
                gd.quymo,
                gd.trangthai,
                gd.trangthaidangky,
                gd.idbantochuc,
                gd.ngaytao,
                gd.ngaycapnhat
             FROM Giaidau gd
             WHERE gd.idgiaidau = :tournament_id
               AND gd.idbantochuc = :organizer_id
             LIMIT 1",
            [
                'tournament_id' => $tournamentId,
                'organizer_id' => $organizerId,
            ]
        );
    }

    public function approvedTeams(int $tournamentId): array
    {
        $statement = $this->db()->prepare(
            "SELECT
                dk.iddangky,
                dk.idgiaidau,
                dk.iddoibong,
                db.tendoibong,
                db.logo,
                db.diaphuong,
                db.trangthai AS trangthaidoibong,
                TRIM(CONCAT(COALESCE(nd.hodem, ''), ' ', COALESCE(nd.ten, ''))) AS huanluyenvien_hoten,
                tk.username AS huanluyenvien_username
             FROM Dangkygiaidau dk
             JOIN Doibong db ON db.iddoibong = dk.iddoibong
             JOIN Huanluyenvien hlv ON hlv.idhuanluyenvien = dk.idhuanluyenvien
             JOIN Nguoidung nd ON nd.idnguoidung = hlv.idnguoidung
             JOIN Taikhoan tk ON tk.idtaikhoan = nd.idtaikhoan
             WHERE dk.idgiaidau = :tournament_id
               AND dk.trangthai = 'DA_DUYET'
               AND db.trangthai = 'HOAT_DONG'
             ORDER BY db.tendoibong"
        );

        $statement->execute(['tournament_id' => $tournamentId]);

        return $statement->fetchAll();
    }

    public function activeVenues(): array
    {
        $statement = $this->db()->prepare(
            "SELECT idsandau, tensandau, diachi, succhua, mota, trangthai
             FROM Sandau
             WHERE trangthai = 'HOAT_DONG'
             ORDER BY tensandau, idsandau"
        );
        $statement->execute();

        return $statement->fetchAll();
    }

    public function groupsForTournament(int $tournamentId, array $filters = []): array
    {
        $where = ['bd.idgiaidau = :tournament_id'];
        $bindings = ['tournament_id' => $tournamentId];

        if (($filters['status'] ?? '') !== '') {
            $where[] = 'bd.trangthai = :status';
            $bindings['status'] = $filters['status'];
        } else {
            $where[] = "bd.trangthai <> 'DA_XOA'";
        }

        if (($filters['q'] ?? '') !== '') {
            $where[] = '(bd.tenbang LIKE :keyword OR bd.mota LIKE :keyword)';
            $bindings['keyword'] = '%' . $filters['q'] . '%';
        }

        $statement = $this->db()->prepare(
            "SELECT
                bd.idbangdau,
                bd.idgiaidau,
                bd.tenbang,
                bd.mota,
                bd.trangthai,
                bd.ngaytao,
                COALESCE(team_stats.total_teams, 0) AS total_teams,
                COALESCE(match_stats.total_matches, 0) AS total_matches
             FROM Bangdau bd
             LEFT JOIN (
                SELECT idbangdau, COUNT(*) AS total_teams
                FROM Doitrongbang
                GROUP BY idbangdau
             ) team_stats ON team_stats.idbangdau = bd.idbangdau
             LEFT JOIN (
                SELECT idbangdau, COUNT(*) AS total_matches
                FROM Trandau
                WHERE trangthai <> 'DA_HUY'
                GROUP BY idbangdau
             ) match_stats ON match_stats.idbangdau = bd.idbangdau
             WHERE " . implode(' AND ', $where) . "
             ORDER BY bd.tenbang, bd.idbangdau"
        );

        $statement->execute($bindings);

        return $statement->fetchAll();
    }

    public function groupById(int $tournamentId, int $groupId): ?array
    {
        return $this->first(
            "SELECT idbangdau, idgiaidau, tenbang, mota, trangthai, ngaytao
             FROM Bangdau
             WHERE idgiaidau = :tournament_id
               AND idbangdau = :group_id
             LIMIT 1",
            [
                'tournament_id' => $tournamentId,
                'group_id' => $groupId,
            ]
        );
    }

    public function groupTeams(int $groupId): array
    {
        $statement = $this->db()->prepare(
            "SELECT
                dtb.iddoitrongbang,
                dtb.idbangdau,
                dtb.iddoibong,
                dtb.ngaythem,
                db.tendoibong,
                db.logo,
                db.diaphuong,
                db.trangthai AS trangthaidoibong
             FROM Doitrongbang dtb
             JOIN Doibong db ON db.iddoibong = dtb.iddoibong
             WHERE dtb.idbangdau = :group_id
             ORDER BY db.tendoibong"
        );

        $statement->execute(['group_id' => $groupId]);

        return $statement->fetchAll();
    }

    public function existsGroupName(int $tournamentId, string $name, ?int $excludeGroupId = null): bool
    {
        $bindings = [
            'tournament_id' => $tournamentId,
            'name' => $name,
        ];
        $sql = "SELECT 1
                FROM Bangdau
                WHERE idgiaidau = :tournament_id
                  AND tenbang = :name";

        if ($excludeGroupId !== null) {
            $sql .= ' AND idbangdau <> :exclude_group_id';
            $bindings['exclude_group_id'] = $excludeGroupId;
        }

        $sql .= ' LIMIT 1';

        return $this->first($sql, $bindings) !== null;
    }

    public function approvedTeamIds(int $tournamentId, array $teamIds): array
    {
        if ($teamIds === []) {
            return [];
        }

        $placeholders = implode(',', array_fill(0, count($teamIds), '?'));
        $statement = $this->db()->prepare(
            "SELECT dk.iddoibong
             FROM Dangkygiaidau dk
             JOIN Doibong db ON db.iddoibong = dk.iddoibong
             WHERE dk.idgiaidau = ?
               AND dk.trangthai = 'DA_DUYET'
               AND db.trangthai = 'HOAT_DONG'
               AND dk.iddoibong IN ($placeholders)"
        );
        $statement->execute(array_merge([$tournamentId], $teamIds));

        return array_map('intval', array_column($statement->fetchAll(), 'iddoibong'));
    }

    public function teamIdsInGroup(int $groupId): array
    {
        $statement = $this->db()->prepare(
            "SELECT iddoibong
             FROM Doitrongbang
             WHERE idbangdau = :group_id"
        );
        $statement->execute(['group_id' => $groupId]);

        return array_map('intval', array_column($statement->fetchAll(), 'iddoibong'));
    }

    public function createGroup(
        int $tournamentId,
        array $group,
        array $teamIds,
        int $actorAccountId,
        ?string $ipAddress,
        string $logNote
    ): int {
        $db = $this->db();

        try {
            $db->beginTransaction();

            $statement = $db->prepare(
                "INSERT INTO Bangdau (idgiaidau, tenbang, mota, trangthai)
                 VALUES (:tournament_id, :name, :description, :status)"
            );
            $statement->execute([
                'tournament_id' => $tournamentId,
                'name' => $group['tenbang'],
                'description' => $group['mota'],
                'status' => $group['trangthai'],
            ]);

            $groupId = (int) $db->lastInsertId();
            $this->replaceGroupTeams($groupId, $teamIds);
            $this->recordSystemLog($actorAccountId, 'Them bang dau', 'Bangdau', $groupId, $ipAddress, $logNote);

            $db->commit();

            return $groupId;
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    public function updateGroup(
        int $groupId,
        array $changes,
        ?array $teamIds,
        int $actorAccountId,
        ?string $ipAddress,
        string $logNote
    ): void {
        $db = $this->db();

        try {
            $db->beginTransaction();

            if ($changes !== []) {
                $sets = [];
                $bindings = ['group_id' => $groupId];

                foreach ($changes as $field => $value) {
                    $sets[] = "{$field} = :{$field}";
                    $bindings[$field] = $value;
                }

                $statement = $db->prepare(
                    'UPDATE Bangdau SET ' . implode(', ', $sets) . ' WHERE idbangdau = :group_id'
                );
                $statement->execute($bindings);

                if ($statement->rowCount() !== 1) {
                    throw new \RuntimeException('GROUP_NOT_UPDATED');
                }
            }

            if ($teamIds !== null) {
                $this->replaceGroupTeams($groupId, $teamIds);
            }

            $this->recordSystemLog($actorAccountId, 'Cap nhat bang dau', 'Bangdau', $groupId, $ipAddress, $logNote);

            $db->commit();
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    public function deleteGroup(
        int $groupId,
        int $actorAccountId,
        ?string $ipAddress,
        string $logNote
    ): void {
        $db = $this->db();

        try {
            $db->beginTransaction();

            $statement = $db->prepare(
                "UPDATE Bangdau
                 SET trangthai = 'DA_XOA'
                 WHERE idbangdau = :group_id
                   AND trangthai <> 'DA_XOA'"
            );
            $statement->execute(['group_id' => $groupId]);

            if ($statement->rowCount() !== 1) {
                throw new \RuntimeException('GROUP_NOT_DELETED');
            }

            $this->recordSystemLog($actorAccountId, 'Xoa bang dau', 'Bangdau', $groupId, $ipAddress, $logNote);

            $db->commit();
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    public function activeMatchCountForGroup(int $groupId): int
    {
        $row = $this->first(
            "SELECT COUNT(*) AS total
             FROM Trandau
             WHERE idbangdau = :group_id
               AND trangthai <> 'DA_HUY'",
            ['group_id' => $groupId]
        );

        return (int) ($row['total'] ?? 0);
    }

    public function matchesForTournament(int $tournamentId, array $filters = []): array
    {
        $where = ['td.idgiaidau = :tournament_id'];
        $bindings = ['tournament_id' => $tournamentId];

        if (($filters['group_id'] ?? null) !== null) {
            $where[] = 'td.idbangdau = :group_id';
            $bindings['group_id'] = (int) $filters['group_id'];
        }

        if (($filters['status'] ?? '') !== '') {
            $where[] = 'td.trangthai = :status';
            $bindings['status'] = $filters['status'];
        } else {
            $where[] = "td.trangthai <> 'DA_HUY'";
        }

        if (($filters['q'] ?? '') !== '') {
            $where[] = "(bd.tenbang LIKE :keyword
                OR d1.tendoibong LIKE :keyword
                OR d2.tendoibong LIKE :keyword
                OR sd.tensandau LIKE :keyword
                OR td.vongdau LIKE :keyword)";
            $bindings['keyword'] = '%' . $filters['q'] . '%';
        }

        $statement = $this->db()->prepare(
            "SELECT
                td.idtrandau,
                td.idgiaidau,
                td.idbangdau,
                bd.tenbang,
                td.iddoibong1,
                d1.tendoibong AS doi1,
                td.iddoibong2,
                d2.tendoibong AS doi2,
                td.idsandau,
                sd.tensandau,
                sd.diachi AS sandau_diachi,
                td.thoigianbatdau,
                td.thoigianketthuc,
                td.vongdau,
                td.trangthai,
                td.ngaytao,
                td.ngaycapnhat
             FROM Trandau td
             LEFT JOIN Bangdau bd ON bd.idbangdau = td.idbangdau
             JOIN Doibong d1 ON d1.iddoibong = td.iddoibong1
             JOIN Doibong d2 ON d2.iddoibong = td.iddoibong2
             JOIN Sandau sd ON sd.idsandau = td.idsandau
             WHERE " . implode(' AND ', $where) . "
             ORDER BY td.thoigianbatdau, td.idtrandau"
        );

        $statement->execute($bindings);

        return $statement->fetchAll();
    }

    public function matchById(int $tournamentId, int $matchId): ?array
    {
        return $this->first(
            "SELECT
                td.idtrandau,
                td.idgiaidau,
                td.idbangdau,
                bd.tenbang,
                td.iddoibong1,
                d1.tendoibong AS doi1,
                td.iddoibong2,
                d2.tendoibong AS doi2,
                td.idsandau,
                sd.tensandau,
                sd.diachi AS sandau_diachi,
                td.thoigianbatdau,
                td.thoigianketthuc,
                td.vongdau,
                td.trangthai,
                td.ngaytao,
                td.ngaycapnhat
             FROM Trandau td
             LEFT JOIN Bangdau bd ON bd.idbangdau = td.idbangdau
             JOIN Doibong d1 ON d1.iddoibong = td.iddoibong1
             JOIN Doibong d2 ON d2.iddoibong = td.iddoibong2
             JOIN Sandau sd ON sd.idsandau = td.idsandau
             WHERE td.idgiaidau = :tournament_id
               AND td.idtrandau = :match_id
             LIMIT 1",
            [
                'tournament_id' => $tournamentId,
                'match_id' => $matchId,
            ]
        );
    }

    public function activeVenueById(int $venueId): ?array
    {
        return $this->first(
            "SELECT idsandau, tensandau, diachi, trangthai
             FROM Sandau
             WHERE idsandau = :venue_id
               AND trangthai = 'HOAT_DONG'
             LIMIT 1",
            ['venue_id' => $venueId]
        );
    }

    public function hasScheduleConflict(
        int $venueId,
        int $teamOneId,
        int $teamTwoId,
        string $startAt,
        ?string $endAt,
        ?int $excludeMatchId = null
    ): ?array {
        $bindings = [
            'venue_id' => $venueId,
            'team_one_a' => $teamOneId,
            'team_two_a' => $teamTwoId,
            'team_one_b' => $teamOneId,
            'team_two_b' => $teamTwoId,
            'start_at' => $startAt,
            'end_at' => $endAt ?? $startAt,
        ];
        $exclude = '';

        if ($excludeMatchId !== null) {
            $exclude = 'AND idtrandau <> :exclude_match_id';
            $bindings['exclude_match_id'] = $excludeMatchId;
        }

        return $this->first(
            "SELECT idtrandau, idsandau, iddoibong1, iddoibong2, thoigianbatdau, thoigianketthuc
             FROM Trandau
             WHERE trangthai <> 'DA_HUY'
               $exclude
               AND (
                    idsandau = :venue_id
                    OR iddoibong1 IN (:team_one_a, :team_two_a)
                    OR iddoibong2 IN (:team_one_b, :team_two_b)
               )
               AND thoigianbatdau < :end_at
               AND COALESCE(thoigianketthuc, thoigianbatdau) > :start_at
             LIMIT 1",
            $bindings
        );
    }

    public function createMatch(
        int $tournamentId,
        array $match,
        int $actorAccountId,
        ?string $ipAddress,
        string $logNote
    ): int {
        $db = $this->db();

        try {
            $db->beginTransaction();

            $statement = $db->prepare(
                "INSERT INTO Trandau
                    (idgiaidau, idbangdau, iddoibong1, iddoibong2, idsandau, thoigianbatdau, thoigianketthuc, vongdau, trangthai)
                 VALUES
                    (:tournament_id, :group_id, :team_one, :team_two, :venue_id, :start_at, :end_at, :round, :status)"
            );
            $statement->execute([
                'tournament_id' => $tournamentId,
                'group_id' => $match['idbangdau'],
                'team_one' => $match['iddoibong1'],
                'team_two' => $match['iddoibong2'],
                'venue_id' => $match['idsandau'],
                'start_at' => $match['thoigianbatdau'],
                'end_at' => $match['thoigianketthuc'],
                'round' => $match['vongdau'],
                'status' => $match['trangthai'],
            ]);

            $matchId = (int) $db->lastInsertId();

            $this->recordStatusHistory('TRAN_DAU', $matchId, null, (string) $match['trangthai'], 'Them tran dau', $actorAccountId);
            $this->recordSystemLog($actorAccountId, 'Them tran dau', 'Trandau', $matchId, $ipAddress, $logNote);

            $db->commit();

            return $matchId;
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    public function updateMatch(
        int $matchId,
        array $changes,
        string $oldStatus,
        ?string $newStatus,
        int $actorAccountId,
        ?string $ipAddress,
        string $logNote
    ): void {
        $db = $this->db();

        try {
            $db->beginTransaction();

            $sets = [];
            $bindings = ['match_id' => $matchId];

            foreach ($changes as $field => $value) {
                $sets[] = "{$field} = :{$field}";
                $bindings[$field] = $value;
            }

            if ($sets === []) {
                throw new \RuntimeException('MATCH_NOT_UPDATED');
            }

            $sets[] = 'ngaycapnhat = CURRENT_TIMESTAMP';

            $statement = $db->prepare(
                'UPDATE Trandau SET ' . implode(', ', $sets) . ' WHERE idtrandau = :match_id'
            );
            $statement->execute($bindings);

            if ($statement->rowCount() !== 1) {
                throw new \RuntimeException('MATCH_NOT_UPDATED');
            }

            if ($newStatus !== null && $newStatus !== $oldStatus) {
                $this->recordStatusHistory('TRAN_DAU', $matchId, $oldStatus, $newStatus, 'Cap nhat trang thai tran dau', $actorAccountId);
            }

            $this->recordSystemLog($actorAccountId, 'Cap nhat tran dau', 'Trandau', $matchId, $ipAddress, $logNote);

            $db->commit();
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    public function deleteMatch(
        int $matchId,
        string $oldStatus,
        int $actorAccountId,
        ?string $ipAddress,
        string $logNote
    ): void {
        $db = $this->db();

        try {
            $db->beginTransaction();

            $statement = $db->prepare(
                "UPDATE Trandau
                 SET trangthai = 'DA_HUY',
                     ngaycapnhat = CURRENT_TIMESTAMP
                 WHERE idtrandau = :match_id
                   AND trangthai <> 'DA_HUY'"
            );
            $statement->execute(['match_id' => $matchId]);

            if ($statement->rowCount() !== 1) {
                throw new \RuntimeException('MATCH_NOT_DELETED');
            }

            $this->recordStatusHistory('TRAN_DAU', $matchId, $oldStatus, 'DA_HUY', 'Xoa tran dau', $actorAccountId);
            $this->recordSystemLog($actorAccountId, 'Xoa tran dau', 'Trandau', $matchId, $ipAddress, $logNote);

            $db->commit();
        } catch (Throwable $exception) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }

            throw $exception;
        }
    }

    private function replaceGroupTeams(int $groupId, array $teamIds): void
    {
        $statement = $this->db()->prepare(
            "DELETE FROM Doitrongbang
             WHERE idbangdau = :group_id"
        );
        $statement->execute(['group_id' => $groupId]);

        if ($teamIds === []) {
            return;
        }

        $statement = $this->db()->prepare(
            "INSERT INTO Doitrongbang (idbangdau, iddoibong)
             VALUES (:group_id, :team_id)"
        );

        foreach ($teamIds as $teamId) {
            $statement->execute([
                'group_id' => $groupId,
                'team_id' => $teamId,
            ]);
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
