<?php

declare(strict_types=1);

namespace App\Backend\Services;

use App\Backend\Core\Http\Request;
use App\Backend\Models\Giaidau;
use RuntimeException;
use Throwable;

final class CoachTournamentRegistrationService
{
    private const REGISTRATION_STATUSES = ['CHO_DUYET', 'DA_DUYET', 'TU_CHOI', 'DA_HUY'];

    public function __construct(
        private ?Giaidau $tournaments = null
    ) {
        $this->tournaments ??= new Giaidau();
    }

    public function tournaments(int $accountId, array $filters = []): array
    {
        $coachResult = $this->activeCoach($accountId);

        if (isset($coachResult['ok']) && $coachResult['ok'] === false) {
            return $coachResult;
        }

        [$normalized, $errors] = $this->filters($filters, false);

        if ($errors !== []) {
            return $this->failure('Bo loc giai dau khong hop le.', 422, $errors);
        }

        return [
            'ok' => true,
            'status' => 200,
            'message' => 'Lay danh sach giai dau co the dang ky thanh cong.',
            'tournaments' => $this->tournaments->openTournamentsForCoach((int) $coachResult['idhuanluyenvien'], $normalized),
            'meta' => [
                'filters' => $normalized,
            ],
        ];
    }

    public function registrations(int $accountId, array $filters = []): array
    {
        $coachResult = $this->activeCoach($accountId);

        if (isset($coachResult['ok']) && $coachResult['ok'] === false) {
            return $coachResult;
        }

        [$normalized, $errors] = $this->filters($filters, true);

        if ($errors !== []) {
            return $this->failure('Bo loc dang ky giai dau khong hop le.', 422, $errors);
        }

        return [
            'ok' => true,
            'status' => 200,
            'message' => 'Lay danh sach dang ky giai dau cua HLV thanh cong.',
            'registrations' => $this->tournaments->registrationsForCoach((int) $coachResult['idhuanluyenvien'], $normalized),
            'meta' => [
                'filters' => $normalized,
                'statuses' => self::REGISTRATION_STATUSES,
            ],
        ];
    }

    public function find(int $registrationId, int $accountId): array
    {
        $coachResult = $this->activeCoach($accountId);

        if (isset($coachResult['ok']) && $coachResult['ok'] === false) {
            return $coachResult;
        }

        $registration = $this->tournaments->findRegistrationForCoach((int) $coachResult['idhuanluyenvien'], $registrationId);

        if ($registration === null) {
            return $this->failure('Khong tim thay dang ky giai dau.', 404);
        }

        return [
            'ok' => true,
            'status' => 200,
            'message' => 'Lay thong tin dang ky giai dau thanh cong.',
            'registration' => $registration,
        ];
    }

    public function register(array $payload, int $accountId, ?Request $request = null): array
    {
        $coachResult = $this->activeCoach($accountId);

        if (isset($coachResult['ok']) && $coachResult['ok'] === false) {
            return $coachResult;
        }

        [$data, $errors] = $this->registrationPayload($payload);

        if ($errors !== []) {
            return $this->failure('Du lieu dang ky giai dau khong hop le.', 422, $errors);
        }

        $coachId = (int) $coachResult['idhuanluyenvien'];
        $tournament = $this->tournaments->findById($data['tournament_id']);

        if ($tournament === null) {
            return $this->failure('Khong tim thay giai dau.', 404);
        }

        if ((string) $tournament['trangthai'] !== 'DA_CONG_BO') {
            return $this->failure('Chi duoc dang ky giai dau da cong bo.', 409);
        }

        if ((string) $tournament['trangthaidangky'] !== 'DANG_MO') {
            return $this->failure('Giai dau hien khong mo dang ky.', 409);
        }

        $team = $this->tournaments->teamForCoach($coachId, $data['team_id']);

        if ($team === null) {
            return $this->failure('Khong tim thay doi bong cua huan luyen vien.', 404);
        }

        if ((string) $team['trangthai'] !== 'HOAT_DONG') {
            return $this->failure('Chi duoc dang ky doi bong dang hoat dong.', 409);
        }

        if ($this->tournaments->registrationExists($data['tournament_id'], $data['team_id'])) {
            return $this->failure('Doi bong da co dang ky trong giai dau nay.', 409);
        }

        if ($this->tournaments->approvedRegistrationCount($data['tournament_id']) >= (int) $tournament['quymo']) {
            return $this->failure('So doi da duyet da dat quy mo giai dau.', 409);
        }

        $content = $data['content'] ?? sprintf(
            'Yeu cau xac nhan doi %s tham gia giai dau %s',
            (string) $team['tendoibong'],
            (string) $tournament['tengiaidau']
        );

        $logNote = $this->limitLogNote(sprintf(
            'HLV #%d dang ky doi #%d "%s" tham gia giai dau #%d "%s".',
            $coachId,
            $data['team_id'],
            (string) $team['tendoibong'],
            $data['tournament_id'],
            (string) $tournament['tengiaidau']
        ));

        try {
            $created = $this->tournaments->registerTeamForTournament(
                $data['tournament_id'],
                $data['team_id'],
                $coachId,
                (int) $tournament['idbantochuc'],
                $content,
                $accountId,
                $request?->ip(),
                $logNote
            );

            return [
                'ok' => true,
                'status' => 201,
                'message' => 'Dang ky giai dau thanh cong, cho ban to chuc duyet.',
                'created' => $created,
                'registration' => $this->tournaments->findRegistrationForCoach($coachId, (int) $created['registration_id']),
            ];
        } catch (Throwable) {
            return $this->failure('Khong the dang ky giai dau.', 500, [
                'database' => 'Loi ghi co so du lieu.',
            ]);
        }
    }

    public function cancel(int $registrationId, array $payload, int $accountId, ?Request $request = null): array
    {
        $coachResult = $this->activeCoach($accountId);

        if (isset($coachResult['ok']) && $coachResult['ok'] === false) {
            return $coachResult;
        }

        $coachId = (int) $coachResult['idhuanluyenvien'];
        $registration = $this->tournaments->findRegistrationForCoach($coachId, $registrationId);

        if ($registration === null) {
            return $this->failure('Khong tim thay dang ky giai dau.', 404);
        }

        if ((string) $registration['trangthai'] !== 'CHO_DUYET') {
            return $this->failure('Chi duoc huy dang ky giai dau dang cho duyet.', 409);
        }

        $reason = $this->reason($payload, 'HLV huy dang ky giai dau');
        $logNote = $this->limitLogNote(sprintf(
            'HLV #%d huy dang ky doi "%s" tham gia giai dau "%s". Ly do: %s',
            $coachId,
            (string) $registration['tendoibong'],
            (string) $registration['tengiaidau'],
            $reason
        ));

        try {
            $this->tournaments->cancelRegistrationForCoach(
                $registrationId,
                $coachId,
                $reason,
                $accountId,
                $request?->ip(),
                $logNote
            );

            return [
                'ok' => true,
                'status' => 200,
                'message' => 'Huy dang ky giai dau thanh cong.',
                'registration' => $this->tournaments->findRegistrationForCoach($coachId, $registrationId),
            ];
        } catch (RuntimeException $exception) {
            if ($exception->getMessage() === 'REGISTRATION_NOT_CANCELLED') {
                return $this->failure('Chi duoc huy dang ky giai dau dang cho duyet.', 409);
            }

            return $this->failure('Khong the huy dang ky giai dau.', 500);
        } catch (Throwable) {
            return $this->failure('Khong the huy dang ky giai dau.', 500, [
                'database' => 'Loi cap nhat co so du lieu.',
            ]);
        }
    }

    private function activeCoach(int $accountId): array
    {
        $coach = $this->tournaments->coachByAccountId($accountId);

        if ($coach === null) {
            return $this->failure('Tai khoan khong co ho so huan luyen vien.', 403);
        }

        if ((string) $coach['trangthai'] !== 'DA_XAC_NHAN') {
            return $this->failure('Huan luyen vien chua duoc xac nhan tu cach.', 403);
        }

        return $coach;
    }

    private function registrationPayload(array $payload): array
    {
        $tournamentRaw = $payload['idgiaidau'] ?? $payload['tournament_id'] ?? null;
        $teamRaw = $payload['iddoibong'] ?? $payload['team_id'] ?? null;
        $content = trim((string) ($payload['noidung'] ?? $payload['content'] ?? $payload['request_content'] ?? ''));
        $errors = [];

        if ($tournamentRaw === null || !ctype_digit((string) $tournamentRaw) || (int) $tournamentRaw <= 0) {
            $errors['idgiaidau'] = 'Giai dau khong hop le.';
        }

        if ($teamRaw === null || !ctype_digit((string) $teamRaw) || (int) $teamRaw <= 0) {
            $errors['iddoibong'] = 'Doi bong khong hop le.';
        }

        if ($content !== '' && strlen($content) > 1000) {
            $errors['noidung'] = 'Noi dung yeu cau toi da 1000 ky tu.';
        }

        return [[
            'tournament_id' => (int) $tournamentRaw,
            'team_id' => (int) $teamRaw,
            'content' => $content === '' ? null : $content,
        ], $errors];
    }

    private function filters(array $filters, bool $includeRegistrationSpecific): array
    {
        $keyword = trim((string) ($filters['q'] ?? $filters['keyword'] ?? ''));
        $status = strtoupper(trim((string) ($filters['status'] ?? $filters['trangthai'] ?? '')));
        $teamId = trim((string) ($filters['team_id'] ?? $filters['iddoibong'] ?? ''));
        $tournamentId = trim((string) ($filters['tournament_id'] ?? $filters['idgiaidau'] ?? ''));
        $from = trim((string) ($filters['from'] ?? $filters['from_date'] ?? $filters['tungay'] ?? ''));
        $to = trim((string) ($filters['to'] ?? $filters['to_date'] ?? $filters['denngay'] ?? ''));
        $errors = [];

        if ($includeRegistrationSpecific && $status !== '' && !in_array($status, self::REGISTRATION_STATUSES, true)) {
            $errors['status'] = 'Trang thai dang ky khong hop le.';
        }

        if ($teamId !== '' && (!ctype_digit($teamId) || (int) $teamId <= 0)) {
            $errors['team_id'] = 'Doi bong khong hop le.';
        }

        if ($tournamentId !== '' && (!ctype_digit($tournamentId) || (int) $tournamentId <= 0)) {
            $errors['tournament_id'] = 'Giai dau khong hop le.';
        }

        if ($from !== '' && !$this->isDate($from)) {
            $errors['from'] = 'Tu ngay khong hop le.';
        }

        if ($to !== '' && !$this->isDate($to)) {
            $errors['to'] = 'Den ngay khong hop le.';
        }

        if ($from !== '' && $to !== '' && empty($errors['from']) && empty($errors['to']) && $from > $to) {
            $errors['date_range'] = 'Tu ngay phai nho hon hoac bang den ngay.';
        }

        return [[
            'q' => $keyword,
            'status' => $status,
            'team_id' => $teamId,
            'tournament_id' => $tournamentId,
            'from' => $from,
            'to' => $to,
        ], $errors];
    }

    private function isDate(string $value): bool
    {
        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $value)) {
            return false;
        }

        [$year, $month, $day] = array_map('intval', explode('-', $value));

        return checkdate($month, $day, $year);
    }

    private function reason(array $payload, string $default): string
    {
        $reason = trim((string) ($payload['lydo'] ?? $payload['reason'] ?? $payload['note'] ?? $payload['ghichu'] ?? ''));
        $reason = $reason === '' ? $default : $reason;

        if (strlen($reason) <= 500) {
            return $reason;
        }

        return substr($reason, 0, 497) . '...';
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
