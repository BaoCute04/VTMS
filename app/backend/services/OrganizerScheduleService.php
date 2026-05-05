<?php

declare(strict_types=1);

namespace App\Backend\Services;

use App\Backend\Core\Http\Request;
use App\Backend\Models\Giaidau;
use App\Backend\Models\Lichthidau;
use DateTimeImmutable;
use RuntimeException;
use Throwable;

final class OrganizerScheduleService
{
    private const GROUP_STATUSES = ['HOAT_DONG', 'DA_XOA', 'DA_KHOA'];
    private const MATCH_STATUSES = ['CHUA_DIEN_RA', 'SAP_DIEN_RA', 'DANG_DIEN_RA', 'TAM_DUNG', 'DA_KET_THUC', 'DA_HUY'];
    private const EDITABLE_MATCH_STATUSES = ['CHUA_DIEN_RA', 'SAP_DIEN_RA'];

    public function __construct(
        private ?Lichthidau $schedules = null,
        private ?Giaidau $tournaments = null
    ) {
        $this->schedules ??= new Lichthidau();
        $this->tournaments ??= new Giaidau();
    }

    public function tournaments(int $accountId, array $filters = []): array
    {
        $organizer = $this->activeOrganizer($accountId);

        if (isset($organizer['ok']) && $organizer['ok'] === false) {
            return $organizer;
        }

        return [
            'ok' => true,
            'status' => 200,
            'message' => 'Lay danh sach giai dau lap lich thanh cong.',
            'tournaments' => $this->schedules->scheduleTournaments((int) $organizer['idbantochuc'], [
                'q' => trim((string) ($filters['q'] ?? $filters['keyword'] ?? '')),
            ]),
        ];
    }

    public function summary(int $tournamentId, int $accountId): array
    {
        $context = $this->scheduleTournament($tournamentId, $accountId);

        if (isset($context['ok']) && $context['ok'] === false) {
            return $context;
        }

        return [
            'ok' => true,
            'status' => 200,
            'message' => 'Lay thong tin lich thi dau thanh cong.',
            'schedule' => [
                'tournament' => $context['tournament'],
                'teams' => $this->schedules->approvedTeams($tournamentId),
                'venues' => $this->schedules->activeVenues(),
                'groups' => $this->groupsWithTeams($tournamentId),
                'matches' => $this->schedules->matchesForTournament($tournamentId),
            ],
        ];
    }

    public function groups(int $tournamentId, int $accountId, array $filters = []): array
    {
        $context = $this->scheduleTournament($tournamentId, $accountId);

        if (isset($context['ok']) && $context['ok'] === false) {
            return $context;
        }

        $normalized = $this->groupFilters($filters);

        if ($normalized['errors'] !== []) {
            return $this->failure('Bo loc bang dau khong hop le.', 422, $normalized['errors']);
        }

        return [
            'ok' => true,
            'status' => 200,
            'message' => 'Lay danh sach bang dau thanh cong.',
            'groups' => $this->groupsWithTeams($tournamentId, $normalized['filters']),
            'meta' => [
                'tournament' => $context['tournament'],
                'teams' => $this->schedules->approvedTeams($tournamentId),
            ],
        ];
    }

    public function group(int $tournamentId, int $groupId, int $accountId): array
    {
        $context = $this->scheduleTournament($tournamentId, $accountId);

        if (isset($context['ok']) && $context['ok'] === false) {
            return $context;
        }

        $group = $this->groupPayload($tournamentId, $groupId);

        if ($group === null) {
            return $this->failure('Khong tim thay bang dau.', 404);
        }

        return [
            'ok' => true,
            'status' => 200,
            'message' => 'Lay thong tin bang dau thanh cong.',
            'group' => $group,
        ];
    }

    public function createGroup(int $tournamentId, array $payload, int $accountId, ?Request $request = null): array
    {
        $context = $this->scheduleTournament($tournamentId, $accountId);

        if (isset($context['ok']) && $context['ok'] === false) {
            return $context;
        }

        [$group, $teamIds, $errors] = $this->validateGroupCreatePayload($tournamentId, $payload);

        if ($errors !== []) {
            return $this->failure('Du lieu bang dau khong hop le.', 422, $errors);
        }

        if ($this->schedules->existsGroupName($tournamentId, $group['tenbang'])) {
            return $this->failure('Ten bang dau da ton tai trong giai dau.', 409, [
                'tenbang' => 'Ten bang dau da ton tai.',
            ]);
        }

        $logNote = $this->limitLogNote(sprintf(
            'Ban to chuc #%d them bang dau "%s" vao giai dau "%s". So doi: %d.',
            (int) $context['organizer']['idbantochuc'],
            $group['tenbang'],
            (string) $context['tournament']['tengiaidau'],
            count($teamIds)
        ));

        try {
            $groupId = $this->schedules->createGroup($tournamentId, $group, $teamIds, $accountId, $request?->ip(), $logNote);

            return [
                'ok' => true,
                'status' => 201,
                'message' => 'Them bang dau thanh cong.',
                'group' => $this->groupPayload($tournamentId, $groupId),
            ];
        } catch (Throwable) {
            return $this->failure('Khong the them bang dau.', 500, [
                'database' => 'Loi ghi co so du lieu.',
            ]);
        }
    }

    public function updateGroup(int $tournamentId, int $groupId, array $payload, int $accountId, ?Request $request = null): array
    {
        $context = $this->scheduleTournament($tournamentId, $accountId);

        if (isset($context['ok']) && $context['ok'] === false) {
            return $context;
        }

        $current = $this->schedules->groupById($tournamentId, $groupId);

        if ($current === null || (string) $current['trangthai'] === 'DA_XOA') {
            return $this->failure('Khong tim thay bang dau.', 404);
        }

        [$changes, $teamIds, $errors, $changedFields] = $this->validateGroupUpdatePayload($tournamentId, $payload, $current);

        if ($errors !== []) {
            return $this->failure('Du lieu cap nhat bang dau khong hop le.', 422, $errors);
        }

        if ($changes === [] && $teamIds === null) {
            return $this->failure('Can gui it nhat mot truong thay doi.', 422, [
                'payload' => 'Khong co du lieu thay doi.',
            ]);
        }

        $name = (string) ($changes['tenbang'] ?? $current['tenbang']);

        if ($this->schedules->existsGroupName($tournamentId, $name, $groupId)) {
            return $this->failure('Ten bang dau da ton tai trong giai dau.', 409, [
                'tenbang' => 'Ten bang dau da ton tai.',
            ]);
        }

        if ($teamIds !== null && $this->schedules->activeMatchCountForGroup($groupId) > 0) {
            return $this->failure('Khong the cap nhat danh sach doi khi bang dau da co tran dau.', 409);
        }

        $logNote = $this->limitLogNote(sprintf(
            'Ban to chuc #%d cap nhat bang dau "%s". Truong thay doi: %s.',
            (int) $context['organizer']['idbantochuc'],
            $name,
            implode(', ', $changedFields)
        ));

        try {
            $this->schedules->updateGroup($groupId, $changes, $teamIds, $accountId, $request?->ip(), $logNote);

            return [
                'ok' => true,
                'status' => 200,
                'message' => 'Cap nhat bang dau thanh cong.',
                'group' => $this->groupPayload($tournamentId, $groupId),
            ];
        } catch (RuntimeException $exception) {
            if ($exception->getMessage() === 'GROUP_NOT_UPDATED') {
                return $this->failure('Khong the cap nhat bang dau.', 409);
            }

            return $this->failure('Khong the cap nhat bang dau.', 500);
        } catch (Throwable) {
            return $this->failure('Khong the cap nhat bang dau.', 500, [
                'database' => 'Loi cap nhat co so du lieu.',
            ]);
        }
    }

    public function deleteGroup(int $tournamentId, int $groupId, int $accountId, ?Request $request = null): array
    {
        $context = $this->scheduleTournament($tournamentId, $accountId);

        if (isset($context['ok']) && $context['ok'] === false) {
            return $context;
        }

        $current = $this->schedules->groupById($tournamentId, $groupId);

        if ($current === null || (string) $current['trangthai'] === 'DA_XOA') {
            return $this->failure('Khong tim thay bang dau.', 404);
        }

        if ($this->schedules->activeMatchCountForGroup($groupId) > 0) {
            return $this->failure('Khong the xoa bang dau da co tran dau.', 409);
        }

        $logNote = $this->limitLogNote(sprintf(
            'Ban to chuc #%d xoa bang dau "%s" trong giai dau "%s".',
            (int) $context['organizer']['idbantochuc'],
            (string) $current['tenbang'],
            (string) $context['tournament']['tengiaidau']
        ));

        try {
            $this->schedules->deleteGroup($groupId, $accountId, $request?->ip(), $logNote);

            return [
                'ok' => true,
                'status' => 200,
                'message' => 'Xoa bang dau thanh cong.',
                'deleted_id' => $groupId,
            ];
        } catch (RuntimeException $exception) {
            if ($exception->getMessage() === 'GROUP_NOT_DELETED') {
                return $this->failure('Khong the xoa bang dau hien tai.', 409);
            }

            return $this->failure('Khong the xoa bang dau.', 500);
        } catch (Throwable) {
            return $this->failure('Khong the xoa bang dau.', 500, [
                'database' => 'Loi cap nhat co so du lieu.',
            ]);
        }
    }

    public function matches(int $tournamentId, int $accountId, array $filters = []): array
    {
        $context = $this->scheduleTournament($tournamentId, $accountId);

        if (isset($context['ok']) && $context['ok'] === false) {
            return $context;
        }

        $normalized = $this->matchFilters($filters);

        if ($normalized['errors'] !== []) {
            return $this->failure('Bo loc tran dau khong hop le.', 422, $normalized['errors']);
        }

        return [
            'ok' => true,
            'status' => 200,
            'message' => 'Lay danh sach tran dau thanh cong.',
            'matches' => $this->schedules->matchesForTournament($tournamentId, $normalized['filters']),
            'meta' => [
                'tournament' => $context['tournament'],
                'groups' => $this->groupsWithTeams($tournamentId),
                'teams' => $this->schedules->approvedTeams($tournamentId),
                'venues' => $this->schedules->activeVenues(),
            ],
        ];
    }

    public function match(int $tournamentId, int $matchId, int $accountId): array
    {
        $context = $this->scheduleTournament($tournamentId, $accountId);

        if (isset($context['ok']) && $context['ok'] === false) {
            return $context;
        }

        $match = $this->schedules->matchById($tournamentId, $matchId);

        if ($match === null) {
            return $this->failure('Khong tim thay tran dau.', 404);
        }

        return [
            'ok' => true,
            'status' => 200,
            'message' => 'Lay thong tin tran dau thanh cong.',
            'match' => $match,
        ];
    }

    public function createMatch(int $tournamentId, array $payload, int $accountId, ?Request $request = null): array
    {
        $context = $this->scheduleTournament($tournamentId, $accountId);

        if (isset($context['ok']) && $context['ok'] === false) {
            return $context;
        }

        [$match, $errors] = $this->validateMatchCreatePayload($tournamentId, $payload);

        if ($errors !== []) {
            return $this->failure('Du lieu tran dau khong hop le.', 422, $errors);
        }

        $logNote = $this->limitLogNote(sprintf(
            'Ban to chuc #%d them tran dau giai "%s": doi #%d vs doi #%d, san #%d, bat dau %s.',
            (int) $context['organizer']['idbantochuc'],
            (string) $context['tournament']['tengiaidau'],
            (int) $match['iddoibong1'],
            (int) $match['iddoibong2'],
            (int) $match['idsandau'],
            (string) $match['thoigianbatdau']
        ));

        try {
            $matchId = $this->schedules->createMatch($tournamentId, $match, $accountId, $request?->ip(), $logNote);

            return [
                'ok' => true,
                'status' => 201,
                'message' => 'Them tran dau thanh cong.',
                'match' => $this->schedules->matchById($tournamentId, $matchId),
            ];
        } catch (Throwable) {
            return $this->failure('Khong the them tran dau.', 500, [
                'database' => 'Loi ghi co so du lieu.',
            ]);
        }
    }

    public function updateMatch(int $tournamentId, int $matchId, array $payload, int $accountId, ?Request $request = null): array
    {
        $context = $this->scheduleTournament($tournamentId, $accountId);

        if (isset($context['ok']) && $context['ok'] === false) {
            return $context;
        }

        $current = $this->schedules->matchById($tournamentId, $matchId);

        if ($current === null) {
            return $this->failure('Khong tim thay tran dau.', 404);
        }

        if (!in_array((string) $current['trangthai'], self::EDITABLE_MATCH_STATUSES, true)) {
            return $this->failure('Chi duoc cap nhat tran dau chua dien ra hoac sap dien ra.', 409);
        }

        [$changes, $errors, $changedFields] = $this->validateMatchUpdatePayload($tournamentId, $payload, $current);

        if ($errors !== []) {
            return $this->failure('Du lieu cap nhat tran dau khong hop le.', 422, $errors);
        }

        if ($changes === []) {
            return $this->failure('Can gui it nhat mot truong thay doi.', 422, [
                'payload' => 'Khong co du lieu thay doi.',
            ]);
        }

        $newStatus = array_key_exists('trangthai', $changes) ? (string) $changes['trangthai'] : null;
        $logNote = $this->limitLogNote(sprintf(
            'Ban to chuc #%d cap nhat tran dau #%d. Truong thay doi: %s.',
            (int) $context['organizer']['idbantochuc'],
            $matchId,
            implode(', ', $changedFields)
        ));

        try {
            $this->schedules->updateMatch(
                $matchId,
                $changes,
                (string) $current['trangthai'],
                $newStatus,
                $accountId,
                $request?->ip(),
                $logNote
            );

            return [
                'ok' => true,
                'status' => 200,
                'message' => 'Cap nhat tran dau thanh cong.',
                'match' => $this->schedules->matchById($tournamentId, $matchId),
            ];
        } catch (RuntimeException $exception) {
            if ($exception->getMessage() === 'MATCH_NOT_UPDATED') {
                return $this->failure('Khong the cap nhat tran dau.', 409);
            }

            return $this->failure('Khong the cap nhat tran dau.', 500);
        } catch (Throwable) {
            return $this->failure('Khong the cap nhat tran dau.', 500, [
                'database' => 'Loi cap nhat co so du lieu.',
            ]);
        }
    }

    public function deleteMatch(int $tournamentId, int $matchId, int $accountId, ?Request $request = null): array
    {
        $context = $this->scheduleTournament($tournamentId, $accountId);

        if (isset($context['ok']) && $context['ok'] === false) {
            return $context;
        }

        $current = $this->schedules->matchById($tournamentId, $matchId);

        if ($current === null || (string) $current['trangthai'] === 'DA_HUY') {
            return $this->failure('Khong tim thay tran dau.', 404);
        }

        if (!in_array((string) $current['trangthai'], self::EDITABLE_MATCH_STATUSES, true)) {
            return $this->failure('Chi duoc xoa tran dau chua dien ra hoac sap dien ra.', 409);
        }

        $logNote = $this->limitLogNote(sprintf(
            'Ban to chuc #%d xoa tran dau #%d trong giai "%s".',
            (int) $context['organizer']['idbantochuc'],
            $matchId,
            (string) $context['tournament']['tengiaidau']
        ));

        try {
            $this->schedules->deleteMatch($matchId, (string) $current['trangthai'], $accountId, $request?->ip(), $logNote);

            return [
                'ok' => true,
                'status' => 200,
                'message' => 'Xoa tran dau thanh cong.',
                'deleted_id' => $matchId,
            ];
        } catch (RuntimeException $exception) {
            if ($exception->getMessage() === 'MATCH_NOT_DELETED') {
                return $this->failure('Khong the xoa tran dau hien tai.', 409);
            }

            return $this->failure('Khong the xoa tran dau.', 500);
        } catch (Throwable) {
            return $this->failure('Khong the xoa tran dau.', 500, [
                'database' => 'Loi cap nhat co so du lieu.',
            ]);
        }
    }

    private function validateGroupCreatePayload(int $tournamentId, array $payload): array
    {
        $errors = [];
        $group = [
            'tenbang' => $this->requiredString($payload, ['tenbang', 'ten', 'name'], 100, 'Ten bang dau', $errors),
            'mota' => $this->nullableString($payload['mota'] ?? $payload['description'] ?? $payload['desc'] ?? null, 500, 'Mo ta', 'mota', $errors),
            'trangthai' => $this->groupStatus($payload['trangthai'] ?? $payload['status'] ?? 'HOAT_DONG', 'trangthai', $errors),
        ];
        $teamIds = $this->teamIds($payload, $errors);

        $this->validateApprovedTeams($tournamentId, $teamIds, $errors);

        return [$group, $teamIds, $errors];
    }

    private function validateGroupUpdatePayload(int $tournamentId, array $payload, array $current): array
    {
        $errors = [];
        $changes = [];
        $changedFields = [];
        $teamIds = null;

        if ($this->hasAnyKey($payload, ['tenbang', 'ten', 'name'])) {
            $name = $this->requiredString($payload, ['tenbang', 'ten', 'name'], 100, 'Ten bang dau', $errors);

            if ($name !== null && $name !== (string) $current['tenbang']) {
                $changes['tenbang'] = $name;
                $changedFields[] = 'tenbang';
            }
        }

        if (array_key_exists('mota', $payload) || array_key_exists('description', $payload) || array_key_exists('desc', $payload)) {
            $description = $this->nullableString($payload['mota'] ?? $payload['description'] ?? $payload['desc'] ?? null, 500, 'Mo ta', 'mota', $errors);

            if ($description !== ($current['mota'] ?? null)) {
                $changes['mota'] = $description;
                $changedFields[] = 'mota';
            }
        }

        if (array_key_exists('trangthai', $payload) || array_key_exists('status', $payload)) {
            $status = $this->groupStatus($payload['trangthai'] ?? $payload['status'] ?? '', 'trangthai', $errors);

            if ($status !== null && $status !== (string) $current['trangthai']) {
                $changes['trangthai'] = $status;
                $changedFields[] = 'trangthai';
            }
        }

        if ($this->hasAnyKey($payload, ['team_ids', 'teams', 'dois', 'iddoibong'])) {
            $teamIds = $this->teamIds($payload, $errors);
            $this->validateApprovedTeams($tournamentId, $teamIds, $errors);

            $currentTeamIds = $this->schedules->teamIdsInGroup((int) $current['idbangdau']);
            sort($currentTeamIds);
            $compareTeamIds = $teamIds;
            sort($compareTeamIds);

            if ($compareTeamIds === $currentTeamIds) {
                $teamIds = null;
            } else {
                $changedFields[] = 'teams';
            }
        }

        return [$changes, $teamIds, $errors, array_values(array_unique($changedFields))];
    }

    private function validateMatchCreatePayload(int $tournamentId, array $payload): array
    {
        $errors = [];
        $match = [
            'idbangdau' => $this->optionalPositiveInt($payload['idbangdau'] ?? $payload['group_id'] ?? null, 'idbangdau', $errors),
            'iddoibong1' => $this->requiredPositiveInt($payload['iddoibong1'] ?? $payload['team_one_id'] ?? $payload['team1'] ?? null, 'iddoibong1', 'Doi 1', $errors),
            'iddoibong2' => $this->requiredPositiveInt($payload['iddoibong2'] ?? $payload['team_two_id'] ?? $payload['team2'] ?? null, 'iddoibong2', 'Doi 2', $errors),
            'idsandau' => $this->requiredPositiveInt($payload['idsandau'] ?? $payload['venue_id'] ?? null, 'idsandau', 'San dau', $errors),
            'thoigianbatdau' => $this->dateTimeValue($payload['thoigianbatdau'] ?? $payload['start_at'] ?? null, 'thoigianbatdau', 'Thoi gian bat dau', $errors),
            'thoigianketthuc' => $this->nullableDateTime($payload['thoigianketthuc'] ?? $payload['end_at'] ?? null, 'thoigianketthuc', 'Thoi gian ket thuc', $errors),
            'vongdau' => $this->requiredString($payload, ['vongdau', 'round'], 100, 'Vong dau', $errors),
            'trangthai' => $this->matchStatus($payload['trangthai'] ?? $payload['status'] ?? 'CHUA_DIEN_RA', 'trangthai', $errors),
        ];

        $this->validateMatchCandidate($tournamentId, $match, null, $errors);

        return [$match, $errors];
    }

    private function validateMatchUpdatePayload(int $tournamentId, array $payload, array $current): array
    {
        $errors = [];
        $candidate = [
            'idbangdau' => $current['idbangdau'] === null ? null : (int) $current['idbangdau'],
            'iddoibong1' => (int) $current['iddoibong1'],
            'iddoibong2' => (int) $current['iddoibong2'],
            'idsandau' => (int) $current['idsandau'],
            'thoigianbatdau' => (string) $current['thoigianbatdau'],
            'thoigianketthuc' => $current['thoigianketthuc'] === null ? null : (string) $current['thoigianketthuc'],
            'vongdau' => (string) $current['vongdau'],
            'trangthai' => (string) $current['trangthai'],
        ];
        $changes = [];
        $changedFields = [];

        $fieldMap = [
            'idbangdau' => ['idbangdau', 'group_id'],
            'iddoibong1' => ['iddoibong1', 'team_one_id', 'team1'],
            'iddoibong2' => ['iddoibong2', 'team_two_id', 'team2'],
            'idsandau' => ['idsandau', 'venue_id'],
        ];

        foreach ($fieldMap as $field => $keys) {
            if (!$this->hasAnyKey($payload, $keys)) {
                continue;
            }

            $value = $field === 'idbangdau'
                ? $this->optionalPositiveInt($payload[$this->firstExistingKey($payload, $keys)] ?? null, $field, $errors)
                : $this->requiredPositiveInt($payload[$this->firstExistingKey($payload, $keys)] ?? null, $field, $field, $errors);

            $candidate[$field] = $value;
        }

        if ($this->hasAnyKey($payload, ['thoigianbatdau', 'start_at'])) {
            $candidate['thoigianbatdau'] = $this->dateTimeValue($payload['thoigianbatdau'] ?? $payload['start_at'] ?? null, 'thoigianbatdau', 'Thoi gian bat dau', $errors);
        }

        if ($this->hasAnyKey($payload, ['thoigianketthuc', 'end_at'])) {
            $candidate['thoigianketthuc'] = $this->nullableDateTime($payload['thoigianketthuc'] ?? $payload['end_at'] ?? null, 'thoigianketthuc', 'Thoi gian ket thuc', $errors);
        }

        if ($this->hasAnyKey($payload, ['vongdau', 'round'])) {
            $candidate['vongdau'] = $this->requiredString($payload, ['vongdau', 'round'], 100, 'Vong dau', $errors);
        }

        if ($this->hasAnyKey($payload, ['trangthai', 'status'])) {
            $candidate['trangthai'] = $this->matchStatus($payload['trangthai'] ?? $payload['status'] ?? '', 'trangthai', $errors);
        }

        $this->validateMatchCandidate($tournamentId, $candidate, (int) $current['idtrandau'], $errors);

        foreach ($candidate as $field => $value) {
            $currentValue = $current[$field] ?? null;

            if ($field === 'idbangdau') {
                $currentValue = $currentValue === null ? null : (int) $currentValue;
            } elseif (in_array($field, ['iddoibong1', 'iddoibong2', 'idsandau'], true)) {
                $currentValue = (int) $currentValue;
            }

            if ($value !== $currentValue) {
                $changes[$field] = $value;
                $changedFields[] = $field;
            }
        }

        return [$changes, $errors, $changedFields];
    }

    private function validateMatchCandidate(int $tournamentId, array $match, ?int $excludeMatchId, array &$errors): void
    {
        foreach (['iddoibong1', 'iddoibong2', 'idsandau', 'thoigianbatdau', 'vongdau', 'trangthai'] as $field) {
            if ($match[$field] === null) {
                return;
            }
        }

        if ((int) $match['iddoibong1'] === (int) $match['iddoibong2']) {
            $errors['iddoibong2'] = 'Hai doi thi dau phai khac nhau.';
        }

        if ($match['thoigianketthuc'] !== null && $match['thoigianketthuc'] <= $match['thoigianbatdau']) {
            $errors['thoigianketthuc'] = 'Thoi gian ket thuc phai lon hon thoi gian bat dau.';
        }

        if ($this->schedules->activeVenueById((int) $match['idsandau']) === null) {
            $errors['idsandau'] = 'San dau khong ton tai hoac khong o trang thai hoat dong.';
        }

        $teamIds = [(int) $match['iddoibong1'], (int) $match['iddoibong2']];
        $approved = $this->schedules->approvedTeamIds($tournamentId, $teamIds);

        foreach ($teamIds as $teamId) {
            if (!in_array($teamId, $approved, true)) {
                $errors['iddoibong'] = 'Doi bong phai duoc duyet tham gia giai va dang hoat dong.';
                break;
            }
        }

        if ($match['idbangdau'] !== null) {
            $group = $this->schedules->groupById($tournamentId, (int) $match['idbangdau']);

            if ($group === null || (string) $group['trangthai'] !== 'HOAT_DONG') {
                $errors['idbangdau'] = 'Bang dau khong ton tai hoac khong hoat dong.';
            } else {
                $groupTeamIds = $this->schedules->teamIdsInGroup((int) $match['idbangdau']);

                foreach ($teamIds as $teamId) {
                    if (!in_array($teamId, $groupTeamIds, true)) {
                        $errors['iddoibong'] = 'Hai doi thi dau phai thuoc bang dau da chon.';
                        break;
                    }
                }
            }
        }

        if ($errors !== []) {
            return;
        }

        $conflict = $this->schedules->hasScheduleConflict(
            (int) $match['idsandau'],
            (int) $match['iddoibong1'],
            (int) $match['iddoibong2'],
            (string) $match['thoigianbatdau'],
            $match['thoigianketthuc'] === null ? null : (string) $match['thoigianketthuc'],
            $excludeMatchId
        );

        if ($conflict !== null) {
            $errors['thoigianbatdau'] = 'Thoi gian bi trung san dau hoac doi bong voi tran dau #' . (string) $conflict['idtrandau'] . '.';
        }
    }

    private function groupPayload(int $tournamentId, int $groupId): ?array
    {
        $group = $this->schedules->groupById($tournamentId, $groupId);

        if ($group === null) {
            return null;
        }

        $group['teams'] = $this->schedules->groupTeams($groupId);
        $group['matches'] = $this->schedules->matchesForTournament($tournamentId, ['group_id' => $groupId]);

        return $group;
    }

    private function groupsWithTeams(int $tournamentId, array $filters = []): array
    {
        $groups = $this->schedules->groupsForTournament($tournamentId, $filters);

        foreach ($groups as &$group) {
            $group['teams'] = $this->schedules->groupTeams((int) $group['idbangdau']);
        }

        return $groups;
    }

    private function scheduleTournament(int $tournamentId, int $accountId): array
    {
        $organizer = $this->activeOrganizer($accountId);

        if (isset($organizer['ok']) && $organizer['ok'] === false) {
            return $organizer;
        }

        $tournament = $this->schedules->tournamentForOrganizer((int) $organizer['idbantochuc'], $tournamentId);

        if ($tournament === null) {
            return $this->failure('Khong tim thay giai dau.', 404);
        }

        if ((string) $tournament['trangthai'] !== 'DA_CONG_BO') {
            return $this->failure('Chi duoc quan ly lich thi dau cua giai dau da cong bo.', 409);
        }

        if ((string) $tournament['trangthaidangky'] !== 'DA_DONG') {
            return $this->failure('Can dong dang ky giai dau truoc khi quan ly lich thi dau.', 409);
        }

        return [
            'organizer' => $organizer,
            'tournament' => $tournament,
        ];
    }

    private function activeOrganizer(int $accountId): array
    {
        $organizer = $this->tournaments->findOrganizerByAccountId($accountId);

        if ($organizer === null) {
            return $this->failure('Tai khoan khong co ho so ban to chuc.', 403);
        }

        if ((string) $organizer['trangthai'] !== 'HOAT_DONG') {
            return $this->failure('Ban to chuc khong o trang thai hoat dong.', 403);
        }

        return $organizer;
    }

    private function groupFilters(array $filters): array
    {
        $status = strtoupper(trim((string) ($filters['status'] ?? $filters['trangthai'] ?? '')));
        $errors = [];

        if ($status !== '' && !in_array($status, self::GROUP_STATUSES, true)) {
            $errors['status'] = 'Trang thai bang dau khong hop le.';
        }

        return [
            'filters' => [
                'q' => trim((string) ($filters['q'] ?? $filters['keyword'] ?? '')),
                'status' => $status,
            ],
            'errors' => $errors,
        ];
    }

    private function matchFilters(array $filters): array
    {
        $status = strtoupper(trim((string) ($filters['status'] ?? $filters['trangthai'] ?? '')));
        $errors = [];
        $groupId = $this->optionalPositiveInt($filters['group_id'] ?? $filters['idbangdau'] ?? null, 'group_id', $errors);

        if ($status !== '' && !in_array($status, self::MATCH_STATUSES, true)) {
            $errors['status'] = 'Trang thai tran dau khong hop le.';
        }

        return [
            'filters' => [
                'q' => trim((string) ($filters['q'] ?? $filters['keyword'] ?? '')),
                'status' => $status,
                'group_id' => $groupId,
            ],
            'errors' => $errors,
        ];
    }

    private function validateApprovedTeams(int $tournamentId, array $teamIds, array &$errors): void
    {
        if ($teamIds === []) {
            return;
        }

        $approved = $this->schedules->approvedTeamIds($tournamentId, $teamIds);

        foreach ($teamIds as $teamId) {
            if (!in_array($teamId, $approved, true)) {
                $errors['team_ids'] = 'Tat ca doi trong bang phai duoc duyet tham gia giai va dang hoat dong.';
                return;
            }
        }
    }

    private function teamIds(array $payload, array &$errors): array
    {
        $source = $payload['team_ids'] ?? $payload['teams'] ?? $payload['dois'] ?? $payload['iddoibong'] ?? [];

        if (is_string($source)) {
            $source = array_filter(array_map('trim', explode(',', $source)), static fn (string $item): bool => $item !== '');
        }

        if (!is_array($source)) {
            $errors['team_ids'] = 'Danh sach doi bong khong hop le.';
            return [];
        }

        $teamIds = [];

        foreach ($source as $index => $item) {
            $value = is_array($item) ? ($item['iddoibong'] ?? $item['team_id'] ?? $item['id'] ?? null) : $item;

            if ($value === null || trim((string) $value) === '' || !ctype_digit((string) $value) || (int) $value <= 0) {
                $errors['team_ids.' . $index] = 'Ma doi bong khong hop le.';
                continue;
            }

            $teamIds[] = (int) $value;
        }

        return array_values(array_unique($teamIds));
    }

    private function requiredString(array $payload, array $keys, int $maxLength, string $label, array &$errors): ?string
    {
        $key = $this->firstExistingKey($payload, $keys);
        $value = trim((string) ($key === null ? '' : $payload[$key]));
        $errorKey = $keys[0];

        if ($value === '') {
            $errors[$errorKey] = $label . ' la bat buoc.';
            return null;
        }

        if (strlen($value) > $maxLength) {
            $errors[$errorKey] = $label . ' khong duoc vuot qua ' . $maxLength . ' ky tu.';
            return null;
        }

        return $value;
    }

    private function nullableString(mixed $value, int $maxLength, string $label, string $errorKey, array &$errors): ?string
    {
        $text = trim((string) ($value ?? ''));

        if ($text === '') {
            return null;
        }

        if (strlen($text) > $maxLength) {
            $errors[$errorKey] = $label . ' khong duoc vuot qua ' . $maxLength . ' ky tu.';
            return null;
        }

        return $text;
    }

    private function requiredPositiveInt(mixed $value, string $errorKey, string $label, array &$errors): ?int
    {
        if ($value === null || trim((string) $value) === '' || !ctype_digit((string) $value) || (int) $value <= 0) {
            $errors[$errorKey] = $label . ' khong hop le.';
            return null;
        }

        return (int) $value;
    }

    private function optionalPositiveInt(mixed $value, string $errorKey, array &$errors): ?int
    {
        if ($value === null || trim((string) $value) === '') {
            return null;
        }

        if (!ctype_digit((string) $value) || (int) $value <= 0) {
            $errors[$errorKey] = 'Gia tri khong hop le.';
            return null;
        }

        return (int) $value;
    }

    private function dateTimeValue(mixed $value, string $errorKey, string $label, array &$errors): ?string
    {
        $text = trim((string) ($value ?? ''));

        if ($text === '') {
            $errors[$errorKey] = $label . ' la bat buoc.';
            return null;
        }

        $normalized = str_replace('T', ' ', $text);

        if (preg_match('/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$/', $normalized)) {
            $normalized .= ':00';
        }

        $date = DateTimeImmutable::createFromFormat('Y-m-d H:i:s', $normalized);

        if (!$date || $date->format('Y-m-d H:i:s') !== $normalized) {
            $errors[$errorKey] = $label . ' phai theo dinh dang YYYY-MM-DD HH:MM[:SS].';
            return null;
        }

        return $normalized;
    }

    private function nullableDateTime(mixed $value, string $errorKey, string $label, array &$errors): ?string
    {
        if ($value === null || trim((string) $value) === '') {
            return null;
        }

        return $this->dateTimeValue($value, $errorKey, $label, $errors);
    }

    private function groupStatus(mixed $value, string $errorKey, array &$errors): ?string
    {
        $status = strtoupper(trim((string) ($value ?? '')));

        if (!in_array($status, self::GROUP_STATUSES, true)) {
            $errors[$errorKey] = 'Trang thai bang dau khong hop le.';
            return null;
        }

        return $status;
    }

    private function matchStatus(mixed $value, string $errorKey, array &$errors): ?string
    {
        $status = strtoupper(trim((string) ($value ?? '')));

        if (!in_array($status, self::MATCH_STATUSES, true)) {
            $errors[$errorKey] = 'Trang thai tran dau khong hop le.';
            return null;
        }

        return $status;
    }

    private function firstExistingKey(array $payload, array $keys): ?string
    {
        foreach ($keys as $key) {
            if (array_key_exists($key, $payload)) {
                return $key;
            }
        }

        return null;
    }

    private function hasAnyKey(array $payload, array $keys): bool
    {
        return $this->firstExistingKey($payload, $keys) !== null;
    }

    private function limitLogNote(string $note): string
    {
        if (strlen($note) <= 1000) {
            return $note;
        }

        return substr($note, 0, 997) . '...';
    }

    private function failure(string $message, int $status, array $errors = []): array
    {
        return [
            'ok' => false,
            'status' => $status,
            'message' => $message,
            'errors' => $errors,
        ];
    }
}
