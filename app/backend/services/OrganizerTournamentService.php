<?php

declare(strict_types=1);

namespace App\Backend\Services;

use App\Backend\Core\Http\Request;
use App\Backend\Models\Giaidau;
use RuntimeException;
use Throwable;

final class OrganizerTournamentService
{
    private const TOURNAMENT_STATUSES = ['CHUA_CONG_BO', 'DA_CONG_BO', 'DANG_DIEN_RA', 'DA_KET_THUC', 'DA_HUY'];
    private const TOURNAMENT_REGISTRATION_STATUSES = ['CHUA_MO', 'DANG_MO', 'DA_DONG'];
    private const REGISTRATION_STATUSES = ['CHO_DUYET', 'DA_DUYET', 'TU_CHOI', 'DA_HUY'];

    public function __construct(private ?Giaidau $tournaments = null)
    {
        $this->tournaments ??= new Giaidau();
    }

    public function all(int $accountId, array $filters = []): array
    {
        $organizerResult = $this->activeOrganizer($accountId);

        if (isset($organizerResult['ok']) && $organizerResult['ok'] === false) {
            return $organizerResult;
        }

        $normalizedFilters = $this->tournamentFilters($filters);

        if (!empty($normalizedFilters['errors'])) {
            return $this->failure('Bo loc giai dau khong hop le.', 422, $normalizedFilters['errors']);
        }

        return [
            'ok' => true,
            'status' => 200,
            'message' => 'Lay danh sach giai dau thanh cong.',
            'tournaments' => $this->tournaments->listForOrganizer((int) $organizerResult['idbantochuc'], $normalizedFilters['filters']),
            'meta' => [
                'filters' => $normalizedFilters['filters'],
            ],
        ];
    }

    public function create(array $payload, int $accountId, ?Request $request = null): array
    {
        $organizerResult = $this->activeOrganizer($accountId);

        if (isset($organizerResult['ok']) && $organizerResult['ok'] === false) {
            return $organizerResult;
        }

        $organizer = $organizerResult;
        [$tournament, $rules, $errors] = $this->validatePayload($payload);

        if ($errors !== []) {
            return $this->failure('Du lieu giai dau khong hop le.', 422, $errors);
        }

        if ($this->tournaments->existsByNameAndStartDate($tournament['tengiaidau'], $tournament['thoigianbatdau'])) {
            return $this->failure('Giai dau da ton tai voi ten va ngay bat dau nay.', 409, [
                'tengiaidau' => 'Ten giai dau va ngay bat dau da ton tai.',
            ]);
        }

        $tournament['idbantochuc'] = (int) $organizer['idbantochuc'];
        $logNote = sprintf(
            'Ban to chuc #%d tao giai dau "%s" voi %d dieu le.',
            (int) $organizer['idbantochuc'],
            $tournament['tengiaidau'],
            count($rules)
        );

        try {
            $tournamentId = $this->tournaments->createTournament(
                $tournament,
                $rules,
                $accountId,
                $request?->ip(),
                $logNote
            );

            return [
                'ok' => true,
                'status' => 201,
                'message' => 'Tao giai dau thanh cong.',
                'tournament' => $this->withRules($tournamentId),
            ];
        } catch (Throwable) {
            return $this->failure('Khong the tao giai dau.', 500, [
                'database' => 'Loi ghi co so du lieu.',
            ]);
        }
    }

    public function find(int $tournamentId, int $accountId): array
    {
        $organizerResult = $this->activeOrganizer($accountId);

        if (isset($organizerResult['ok']) && $organizerResult['ok'] === false) {
            return $organizerResult;
        }

        $tournament = $this->withRules($tournamentId);

        if ($tournament === null || (int) $tournament['idbantochuc'] !== (int) $organizerResult['idbantochuc']) {
            return $this->failure('Khong tim thay giai dau.', 404);
        }

        return [
            'ok' => true,
            'status' => 200,
            'message' => 'Lay thong tin giai dau thanh cong.',
            'tournament' => $tournament,
        ];
    }

    public function update(int $tournamentId, array $payload, int $accountId, ?Request $request = null): array
    {
        $organizerResult = $this->activeOrganizer($accountId);

        if (isset($organizerResult['ok']) && $organizerResult['ok'] === false) {
            return $organizerResult;
        }

        $organizer = $organizerResult;
        $current = $this->withRules($tournamentId);

        if ($current === null || (int) $current['idbantochuc'] !== (int) $organizer['idbantochuc']) {
            return $this->failure('Khong tim thay giai dau.', 404);
        }

        if ((string) $current['trangthai'] !== 'CHUA_CONG_BO') {
            return $this->failure('Chi duoc cap nhat giai dau chua cong bo.', 409);
        }

        [$tournament, $rules, $errors, $changedFields] = $this->validateUpdatePayload($payload, $current);

        if ($errors !== []) {
            return $this->failure('Du lieu cap nhat giai dau khong hop le.', 422, $errors);
        }

        $name = $tournament['tengiaidau'] ?? (string) $current['tengiaidau'];
        $startDate = $tournament['thoigianbatdau'] ?? (string) $current['thoigianbatdau'];

        if ($this->tournaments->existsByNameAndStartDate($name, $startDate, $tournamentId)) {
            return $this->failure('Giai dau da ton tai voi ten va ngay bat dau nay.', 409, [
                'tengiaidau' => 'Ten giai dau va ngay bat dau da ton tai.',
            ]);
        }

        $logNote = sprintf(
            'Ban to chuc #%d cap nhat giai dau "%s". Truong thay doi: %s.',
            (int) $organizer['idbantochuc'],
            $name,
            implode(', ', $changedFields)
        );

        try {
            $this->tournaments->updateTournament(
                $tournamentId,
                $tournament,
                $rules,
                $accountId,
                $request?->ip(),
                $logNote
            );

            return [
                'ok' => true,
                'status' => 200,
                'message' => 'Cap nhat giai dau thanh cong.',
                'tournament' => $this->withRules($tournamentId),
            ];
        } catch (RuntimeException $exception) {
            if ($exception->getMessage() === 'TOURNAMENT_NOT_UPDATED') {
                return $this->failure('Chi duoc cap nhat giai dau chua cong bo.', 409);
            }

            return $this->failure('Khong the cap nhat giai dau.', 500);
        } catch (Throwable) {
            return $this->failure('Khong the cap nhat giai dau.', 500, [
                'database' => 'Loi ghi co so du lieu.',
            ]);
        }
    }

    public function delete(int $tournamentId, int $accountId, ?Request $request = null): array
    {
        $organizerResult = $this->activeOrganizer($accountId);

        if (isset($organizerResult['ok']) && $organizerResult['ok'] === false) {
            return $organizerResult;
        }

        $organizer = $organizerResult;
        $current = $this->withRules($tournamentId);

        if ($current === null || (int) $current['idbantochuc'] !== (int) $organizer['idbantochuc']) {
            return $this->failure('Khong tim thay giai dau.', 404);
        }

        if ((string) $current['trangthai'] !== 'CHUA_CONG_BO') {
            return $this->failure('Chi duoc xoa giai dau chua cong bo.', 409);
        }

        $logNote = sprintf(
            'Ban to chuc #%d xoa giai dau "%s" dang o trang thai CHUA_CONG_BO.',
            (int) $organizer['idbantochuc'],
            (string) $current['tengiaidau']
        );

        try {
            $this->tournaments->deleteTournament($tournamentId, $accountId, $request?->ip(), $logNote);

            return [
                'ok' => true,
                'status' => 200,
                'message' => 'Xoa giai dau thanh cong.',
                'deleted_id' => $tournamentId,
            ];
        } catch (RuntimeException $exception) {
            if ($exception->getMessage() === 'TOURNAMENT_NOT_DELETED') {
                return $this->failure('Chi duoc xoa giai dau chua cong bo.', 409);
            }

            return $this->failure('Khong the xoa giai dau.', 500);
        } catch (Throwable) {
            return $this->failure('Khong the xoa giai dau. Co the giai dau dang co du lieu lien quan.', 409, [
                'database' => 'Loi xoa du lieu hoac rang buoc khoa ngoai.',
            ]);
        }
    }

    public function publish(int $tournamentId, int $accountId, ?Request $request = null): array
    {
        $organizerResult = $this->activeOrganizer($accountId);

        if (isset($organizerResult['ok']) && $organizerResult['ok'] === false) {
            return $organizerResult;
        }

        $organizer = $organizerResult;
        $current = $this->withRules($tournamentId);

        if ($current === null || (int) $current['idbantochuc'] !== (int) $organizer['idbantochuc']) {
            return $this->failure('Khong tim thay giai dau.', 404);
        }

        if ((string) $current['trangthai'] !== 'CHUA_CONG_BO') {
            return $this->failure('Chi duoc cong bo giai dau chua cong bo.', 409);
        }

        $errors = $this->validatePublishableTournament($current);

        if ($errors !== []) {
            return $this->failure('Giai dau chua du thong tin de cong bo.', 422, $errors);
        }

        $logNote = sprintf(
            'Ban to chuc #%d cong bo giai dau "%s".',
            (int) $organizer['idbantochuc'],
            (string) $current['tengiaidau']
        );

        try {
            $this->tournaments->publishTournament($tournamentId, $accountId, $request?->ip(), $logNote);

            return [
                'ok' => true,
                'status' => 200,
                'message' => 'Cong bo giai dau thanh cong.',
                'tournament' => $this->withRules($tournamentId),
            ];
        } catch (RuntimeException $exception) {
            if ($exception->getMessage() === 'TOURNAMENT_NOT_PUBLISHED') {
                return $this->failure('Chi duoc cong bo giai dau chua cong bo.', 409);
            }

            return $this->failure('Khong the cong bo giai dau.', 500);
        } catch (Throwable) {
            return $this->failure('Khong the cong bo giai dau.', 500, [
                'database' => 'Loi cap nhat co so du lieu.',
            ]);
        }
    }

    public function registrations(int $tournamentId, int $accountId, array $filters = []): array
    {
        $organizerResult = $this->activeOrganizer($accountId);

        if (isset($organizerResult['ok']) && $organizerResult['ok'] === false) {
            return $organizerResult;
        }

        $organizer = $organizerResult;
        $current = $this->withRules($tournamentId);

        if ($current === null || (int) $current['idbantochuc'] !== (int) $organizer['idbantochuc']) {
            return $this->failure('Khong tim thay giai dau.', 404);
        }

        $normalizedFilters = $this->registrationFilters($filters);

        if (!empty($normalizedFilters['errors'])) {
            return $this->failure('Bo loc danh sach dang ky khong hop le.', 422, $normalizedFilters['errors']);
        }

        return [
            'ok' => true,
            'status' => 200,
            'message' => 'Lay danh sach dang ky giai dau thanh cong.',
            'registrations' => $this->tournaments->registrationsForTournament($tournamentId, $normalizedFilters['filters']),
            'meta' => [
                'tournament' => [
                    'idgiaidau' => (int) $current['idgiaidau'],
                    'tengiaidau' => (string) $current['tengiaidau'],
                    'trangthai' => (string) $current['trangthai'],
                    'trangthaidangky' => (string) $current['trangthaidangky'],
                    'quymo' => (int) $current['quymo'],
                ],
                'stats' => $this->tournaments->registrationStatsForTournament($tournamentId),
            ],
        ];
    }

    public function openRegistrations(int $tournamentId, int $accountId, ?Request $request = null): array
    {
        return $this->changeRegistrationWindow($tournamentId, $accountId, 'DANG_MO', $request);
    }

    public function closeRegistrations(int $tournamentId, int $accountId, ?Request $request = null): array
    {
        return $this->changeRegistrationWindow($tournamentId, $accountId, 'DA_DONG', $request);
    }

    public function approveRegistration(int $tournamentId, int $registrationId, int $accountId, ?Request $request = null): array
    {
        return $this->decideRegistration($tournamentId, $registrationId, $accountId, 'DA_DUYET', null, $request);
    }

    public function rejectRegistration(int $tournamentId, int $registrationId, array $payload, int $accountId, ?Request $request = null): array
    {
        $reason = trim((string) ($payload['lydotuchoi'] ?? $payload['ly_do'] ?? $payload['reason'] ?? $payload['note'] ?? ''));

        if ($reason === '') {
            return $this->failure('Ly do tu choi la bat buoc.', 422, [
                'lydotuchoi' => 'Can nhap ly do tu choi.',
            ]);
        }

        if (strlen($reason) > 1000) {
            return $this->failure('Ly do tu choi khong hop le.', 422, [
                'lydotuchoi' => 'Ly do tu choi khong duoc vuot qua 1000 ky tu.',
            ]);
        }

        return $this->decideRegistration($tournamentId, $registrationId, $accountId, 'TU_CHOI', $reason, $request);
    }

    private function validatePayload(array $payload): array
    {
        $errors = [];

        $tournament = [
            'tengiaidau' => $this->requiredString($payload, ['tengiaidau', 'ten'], 300, 'Ten giai dau', $errors),
            'mota' => $this->nullableString($payload['mota'] ?? $payload['description'] ?? null, 1000, 'Mo ta', 'mota', $errors),
            'thoigianbatdau' => $this->dateValue($payload['thoigianbatdau'] ?? $payload['ngaybatdau'] ?? $payload['start_date'] ?? null, 'thoigianbatdau', 'Ngay bat dau', $errors),
            'thoigianketthuc' => $this->dateValue($payload['thoigianketthuc'] ?? $payload['ngayketthuc'] ?? $payload['end_date'] ?? null, 'thoigianketthuc', 'Ngay ket thuc', $errors),
            'diadiem' => $this->requiredString($payload, ['diadiem', 'dia_diem', 'location'], 500, 'Dia diem', $errors),
            'quymo' => $this->positiveInt($payload['quymo'] ?? $payload['quy_mo'] ?? $payload['scale'] ?? null, 'quymo', 'Quy mo', $errors),
            'hinhanh' => $this->nullableString($payload['hinhanh'] ?? $payload['image'] ?? null, 500, 'Hinh anh', 'hinhanh', $errors),
        ];

        if ($tournament['thoigianbatdau'] !== null && $tournament['thoigianketthuc'] !== null) {
            if ($tournament['thoigianketthuc'] < $tournament['thoigianbatdau']) {
                $errors['thoigianketthuc'] = 'Ngay ket thuc phai lon hon hoac bang ngay bat dau.';
            }
        }

        $rules = $this->rules($payload, $errors);

        return [$tournament, $rules, $errors];
    }

    private function validateUpdatePayload(array $payload, array $current): array
    {
        $errors = [];
        $tournament = [];
        $changedFields = [];
        $rules = null;

        if ($this->hasAnyKey($payload, ['tengiaidau', 'ten'])) {
            $name = $this->requiredString($payload, ['tengiaidau', 'ten'], 300, 'Ten giai dau', $errors);

            if ($name !== null && $name !== (string) $current['tengiaidau']) {
                $tournament['tengiaidau'] = $name;
                $changedFields[] = 'tengiaidau';
            }
        }

        if (array_key_exists('mota', $payload) || array_key_exists('description', $payload)) {
            $description = $this->nullableString($payload['mota'] ?? $payload['description'] ?? null, 1000, 'Mo ta', 'mota', $errors);

            if ($description !== ($current['mota'] ?? null)) {
                $tournament['mota'] = $description;
                $changedFields[] = 'mota';
            }
        }

        if ($this->hasAnyKey($payload, ['thoigianbatdau', 'ngaybatdau', 'start_date'])) {
            $startDate = $this->dateValue($payload['thoigianbatdau'] ?? $payload['ngaybatdau'] ?? $payload['start_date'] ?? null, 'thoigianbatdau', 'Ngay bat dau', $errors);

            if ($startDate !== null && $startDate !== (string) $current['thoigianbatdau']) {
                $tournament['thoigianbatdau'] = $startDate;
                $changedFields[] = 'thoigianbatdau';
            }
        }

        if ($this->hasAnyKey($payload, ['thoigianketthuc', 'ngayketthuc', 'end_date'])) {
            $endDate = $this->dateValue($payload['thoigianketthuc'] ?? $payload['ngayketthuc'] ?? $payload['end_date'] ?? null, 'thoigianketthuc', 'Ngay ket thuc', $errors);

            if ($endDate !== null && $endDate !== (string) $current['thoigianketthuc']) {
                $tournament['thoigianketthuc'] = $endDate;
                $changedFields[] = 'thoigianketthuc';
            }
        }

        if ($this->hasAnyKey($payload, ['diadiem', 'dia_diem', 'location'])) {
            $location = $this->requiredString($payload, ['diadiem', 'dia_diem', 'location'], 500, 'Dia diem', $errors);

            if ($location !== null && $location !== (string) $current['diadiem']) {
                $tournament['diadiem'] = $location;
                $changedFields[] = 'diadiem';
            }
        }

        if ($this->hasAnyKey($payload, ['quymo', 'quy_mo', 'scale'])) {
            $scale = $this->positiveInt($payload['quymo'] ?? $payload['quy_mo'] ?? $payload['scale'] ?? null, 'quymo', 'Quy mo', $errors);

            if ($scale !== null && $scale !== (int) $current['quymo']) {
                $tournament['quymo'] = $scale;
                $changedFields[] = 'quymo';
            }
        }

        if (array_key_exists('hinhanh', $payload) || array_key_exists('image', $payload)) {
            $image = $this->nullableString($payload['hinhanh'] ?? $payload['image'] ?? null, 500, 'Hinh anh', 'hinhanh', $errors);

            if ($image !== ($current['hinhanh'] ?? null)) {
                $tournament['hinhanh'] = $image;
                $changedFields[] = 'hinhanh';
            }
        }

        if ($this->hasAnyKey($payload, ['dieule', 'dieu_le', 'rules'])) {
            $rules = $this->rules($payload, $errors);
            $changedFields[] = 'dieule';
        }

        $start = $tournament['thoigianbatdau'] ?? (string) $current['thoigianbatdau'];
        $end = $tournament['thoigianketthuc'] ?? (string) $current['thoigianketthuc'];

        if ($start !== '' && $end !== '' && $end < $start) {
            $errors['thoigianketthuc'] = 'Ngay ket thuc phai lon hon hoac bang ngay bat dau.';
        }

        if ($tournament === [] && $rules === null && $errors === []) {
            $errors['payload'] = 'Can gui it nhat mot truong can cap nhat.';
        }

        return [$tournament, $rules, $errors, array_values(array_unique($changedFields))];
    }

    private function changeRegistrationWindow(int $tournamentId, int $accountId, string $targetStatus, ?Request $request = null): array
    {
        $organizerResult = $this->activeOrganizer($accountId);

        if (isset($organizerResult['ok']) && $organizerResult['ok'] === false) {
            return $organizerResult;
        }

        $organizer = $organizerResult;
        $current = $this->withRules($tournamentId);

        if ($current === null || (int) $current['idbantochuc'] !== (int) $organizer['idbantochuc']) {
            return $this->failure('Khong tim thay giai dau.', 404);
        }

        if ((string) $current['trangthai'] !== 'DA_CONG_BO') {
            return $this->failure('Giai dau phai duoc cong bo truoc khi quan ly dang ky.', 409);
        }

        $oldStatus = (string) $current['trangthaidangky'];

        if ($targetStatus === 'DANG_MO' && $oldStatus === 'DANG_MO') {
            return $this->failure('Dang ky giai dau dang mo.', 409);
        }

        if ($targetStatus === 'DA_DONG' && $oldStatus === 'DA_DONG') {
            return $this->failure('Dang ky giai dau da dong.', 409);
        }

        if ($targetStatus === 'DA_DONG' && $oldStatus === 'CHUA_MO') {
            return $this->failure('Chua the dong dang ky khi giai dau chua mo dang ky.', 409);
        }

        $action = $targetStatus === 'DANG_MO' ? 'mo' : 'dong';
        $logNote = sprintf(
            'Ban to chuc #%d %s dang ky giai dau "%s". Trang thai: %s -> %s.',
            (int) $organizer['idbantochuc'],
            $action,
            (string) $current['tengiaidau'],
            $oldStatus,
            $targetStatus
        );
        $logNote = $this->limitLogNote($logNote);

        try {
            $this->tournaments->updateRegistrationWindow(
                $tournamentId,
                $oldStatus,
                $targetStatus,
                $accountId,
                $request?->ip(),
                $logNote
            );

            return [
                'ok' => true,
                'status' => 200,
                'message' => $targetStatus === 'DANG_MO' ? 'Mo dang ky giai dau thanh cong.' : 'Dong dang ky giai dau thanh cong.',
                'tournament' => $this->withRules($tournamentId),
            ];
        } catch (RuntimeException $exception) {
            if ($exception->getMessage() === 'REGISTRATION_WINDOW_NOT_UPDATED') {
                return $this->failure('Khong the cap nhat trang thai dang ky giai dau hien tai.', 409);
            }

            return $this->failure('Khong the cap nhat trang thai dang ky giai dau.', 500);
        } catch (Throwable) {
            return $this->failure('Khong the cap nhat trang thai dang ky giai dau.', 500, [
                'database' => 'Loi cap nhat co so du lieu.',
            ]);
        }
    }

    private function decideRegistration(
        int $tournamentId,
        int $registrationId,
        int $accountId,
        string $targetStatus,
        ?string $rejectionReason,
        ?Request $request = null
    ): array {
        $organizerResult = $this->activeOrganizer($accountId);

        if (isset($organizerResult['ok']) && $organizerResult['ok'] === false) {
            return $organizerResult;
        }

        $organizer = $organizerResult;
        $current = $this->withRules($tournamentId);

        if ($current === null || (int) $current['idbantochuc'] !== (int) $organizer['idbantochuc']) {
            return $this->failure('Khong tim thay giai dau.', 404);
        }

        if ((string) $current['trangthai'] !== 'DA_CONG_BO') {
            return $this->failure('Giai dau phai duoc cong bo truoc khi duyet dang ky.', 409);
        }

        $registration = $this->tournaments->findRegistration($tournamentId, $registrationId);

        if ($registration === null) {
            return $this->failure('Khong tim thay dang ky giai dau.', 404);
        }

        if ((string) $registration['trangthai'] !== 'CHO_DUYET') {
            return $this->failure('Chi duoc xu ly dang ky dang cho duyet.', 409);
        }

        if ($targetStatus === 'DA_DUYET') {
            if ((string) $registration['doibong_trangthai'] !== 'HOAT_DONG') {
                return $this->failure('Chi duoc duyet doi bong dang hoat dong.', 409);
            }

            if ($this->tournaments->approvedRegistrationCount($tournamentId) >= (int) $current['quymo']) {
                return $this->failure('So doi da duyet da dat quy mo giai dau.', 409, [
                    'quymo' => 'Khong the duyet them doi bong vi da dat gioi han quy mo.',
                ]);
            }
        }

        $action = $targetStatus === 'DA_DUYET' ? 'duyet' : 'tu choi';
        $logNote = sprintf(
            'Ban to chuc #%d %s dang ky cua doi "%s" vao giai dau "%s".',
            (int) $organizer['idbantochuc'],
            $action,
            (string) $registration['tendoibong'],
            (string) $current['tengiaidau']
        );

        if ($rejectionReason !== null) {
            $logNote .= ' Ly do: ' . $rejectionReason;
        }

        $logNote = $this->limitLogNote($logNote);

        try {
            $this->tournaments->decideRegistration(
                $tournamentId,
                $registrationId,
                'CHO_DUYET',
                $targetStatus,
                $rejectionReason,
                $accountId,
                $request?->ip(),
                $logNote
            );

            return [
                'ok' => true,
                'status' => 200,
                'message' => $targetStatus === 'DA_DUYET' ? 'Duyet dang ky thanh cong.' : 'Tu choi dang ky thanh cong.',
                'registration' => $this->tournaments->findRegistration($tournamentId, $registrationId),
            ];
        } catch (RuntimeException $exception) {
            if ($exception->getMessage() === 'REGISTRATION_NOT_DECIDED') {
                return $this->failure('Chi duoc xu ly dang ky dang cho duyet.', 409);
            }

            return $this->failure('Khong the xu ly dang ky giai dau.', 500);
        } catch (Throwable) {
            return $this->failure('Khong the xu ly dang ky giai dau.', 500, [
                'database' => 'Loi cap nhat co so du lieu.',
            ]);
        }
    }

    private function registrationFilters(array $filters): array
    {
        $status = strtoupper(trim((string) ($filters['status'] ?? $filters['trangthai'] ?? '')));
        $keyword = trim((string) ($filters['q'] ?? $filters['keyword'] ?? ''));
        $errors = [];

        if ($status !== '' && !in_array($status, self::REGISTRATION_STATUSES, true)) {
            $errors['status'] = 'Trang thai dang ky khong hop le.';
        }

        return [
            'filters' => [
                'status' => $status,
                'q' => $keyword,
            ],
            'errors' => $errors,
        ];
    }

    private function tournamentFilters(array $filters): array
    {
        $status = strtoupper(trim((string) ($filters['status'] ?? $filters['trangthai'] ?? '')));
        $registrationStatus = strtoupper(trim((string) ($filters['registration_status'] ?? $filters['reg_status'] ?? $filters['trangthaidangky'] ?? '')));
        $keyword = trim((string) ($filters['q'] ?? $filters['keyword'] ?? ''));
        $from = trim((string) ($filters['from'] ?? ''));
        $to = trim((string) ($filters['to'] ?? ''));
        $errors = [];

        if ($status !== '' && !in_array($status, self::TOURNAMENT_STATUSES, true)) {
            $errors['status'] = 'Trang thai giai dau khong hop le.';
        }

        if ($registrationStatus !== '' && !in_array($registrationStatus, self::TOURNAMENT_REGISTRATION_STATUSES, true)) {
            $errors['registration_status'] = 'Trang thai dang ky khong hop le.';
        }

        if ($from !== '' && !$this->isValidDate($from)) {
            $errors['from'] = 'Ngay bat dau loc khong hop le.';
        }

        if ($to !== '' && !$this->isValidDate($to)) {
            $errors['to'] = 'Ngay ket thuc loc khong hop le.';
        }

        if ($from !== '' && $to !== '' && $this->isValidDate($from) && $this->isValidDate($to) && $to < $from) {
            $errors['to'] = 'Ngay ket thuc loc phai lon hon hoac bang ngay bat dau loc.';
        }

        return [
            'filters' => [
                'status' => $status,
                'registration_status' => $registrationStatus,
                'q' => $keyword,
                'from' => $from,
                'to' => $to,
            ],
            'errors' => $errors,
        ];
    }

    private function isValidDate(string $date): bool
    {
        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $date)) {
            return false;
        }

        [$year, $month, $day] = array_map('intval', explode('-', $date));

        return checkdate($month, $day, $year);
    }

    private function limitLogNote(string $note): string
    {
        if (strlen($note) <= 1000) {
            return $note;
        }

        return substr($note, 0, 997) . '...';
    }

    private function validatePublishableTournament(array $tournament): array
    {
        $errors = [];
        $requiredTextFields = [
            'tengiaidau' => 'Ten giai dau la bat buoc.',
            'thoigianbatdau' => 'Ngay bat dau la bat buoc.',
            'thoigianketthuc' => 'Ngay ket thuc la bat buoc.',
            'diadiem' => 'Dia diem la bat buoc.',
        ];

        foreach ($requiredTextFields as $field => $message) {
            if (trim((string) ($tournament[$field] ?? '')) === '') {
                $errors[$field] = $message;
            }
        }

        if ((int) ($tournament['quymo'] ?? 0) <= 0) {
            $errors['quymo'] = 'Quy mo phai lon hon 0.';
        }

        $startDate = trim((string) ($tournament['thoigianbatdau'] ?? ''));
        $endDate = trim((string) ($tournament['thoigianketthuc'] ?? ''));

        if ($startDate !== '' && $endDate !== '' && $endDate < $startDate) {
            $errors['thoigianketthuc'] = 'Ngay ket thuc phai lon hon hoac bang ngay bat dau.';
        }

        $rules = $tournament['dieule'] ?? [];
        $hasValidRule = false;

        if (is_array($rules)) {
            foreach ($rules as $rule) {
                if (!is_array($rule)) {
                    continue;
                }

                if (trim((string) ($rule['tieude'] ?? '')) !== '' && trim((string) ($rule['noidung'] ?? '')) !== '') {
                    $hasValidRule = true;
                    break;
                }
            }
        }

        if (!$hasValidRule) {
            $errors['dieule'] = 'Can co it nhat mot dieu le hop le de cong bo giai dau.';
        }

        return $errors;
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

    private function dateValue(mixed $value, string $errorKey, string $label, array &$errors): ?string
    {
        $date = trim((string) ($value ?? ''));

        if ($date === '') {
            $errors[$errorKey] = $label . ' la bat buoc.';
            return null;
        }

        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $date)) {
            $errors[$errorKey] = $label . ' phai theo dinh dang YYYY-MM-DD.';
            return null;
        }

        [$year, $month, $day] = array_map('intval', explode('-', $date));

        if (!checkdate($month, $day, $year)) {
            $errors[$errorKey] = $label . ' khong hop le.';
            return null;
        }

        return $date;
    }

    private function positiveInt(mixed $value, string $errorKey, string $label, array &$errors): ?int
    {
        if ($value === null || trim((string) $value) === '') {
            $errors[$errorKey] = $label . ' la bat buoc.';
            return null;
        }

        if (!ctype_digit((string) $value)) {
            $errors[$errorKey] = $label . ' phai la so nguyen duong.';
            return null;
        }

        $number = (int) $value;

        if ($number <= 0) {
            $errors[$errorKey] = $label . ' phai lon hon 0.';
            return null;
        }

        return $number;
    }

    private function rules(array $payload, array &$errors): array
    {
        $source = $payload['dieule'] ?? $payload['dieu_le'] ?? $payload['rules'] ?? null;

        if (is_string($source)) {
            $content = trim($source);

            if ($content === '') {
                $errors['dieule'] = 'Noi dung dieu le la bat buoc.';
                return [];
            }

            if (strlen($content) > 3000) {
                $errors['dieule'] = 'Noi dung dieu le khong duoc vuot qua 3000 ky tu.';
                return [];
            }

            return [[
                'tieude' => trim((string) ($payload['tieude_dieule'] ?? 'Dieu le giai dau')),
                'noidung' => $content,
                'filedinhkem' => $this->nullableString($payload['filedinhkem'] ?? null, 500, 'File dinh kem', 'filedinhkem', $errors),
            ]];
        }

        if (!is_array($source)) {
            $errors['dieule'] = 'Can cung cap it nhat mot dieu le giai dau.';
            return [];
        }

        $items = $this->isRuleObject($source) ? [$source] : $source;
        $rules = [];
        $titles = [];

        foreach ($items as $index => $item) {
            if (!is_array($item)) {
                $errors['dieule.' . $index] = 'Dieu le khong hop le.';
                continue;
            }

            $title = trim((string) ($item['tieude'] ?? $item['title'] ?? ''));
            $content = trim((string) ($item['noidung'] ?? $item['content'] ?? ''));
            $attachment = $this->nullableString($item['filedinhkem'] ?? $item['attachment'] ?? null, 500, 'File dinh kem', 'dieule.' . $index . '.filedinhkem', $errors);

            if ($title === '') {
                $errors['dieule.' . $index . '.tieude'] = 'Tieu de dieu le la bat buoc.';
                continue;
            }

            if (strlen($title) > 300) {
                $errors['dieule.' . $index . '.tieude'] = 'Tieu de dieu le khong duoc vuot qua 300 ky tu.';
                continue;
            }

            if ($content === '') {
                $errors['dieule.' . $index . '.noidung'] = 'Noi dung dieu le la bat buoc.';
                continue;
            }

            if (strlen($content) > 3000) {
                $errors['dieule.' . $index . '.noidung'] = 'Noi dung dieu le khong duoc vuot qua 3000 ky tu.';
                continue;
            }

            $key = function_exists('mb_strtolower') ? mb_strtolower($title, 'UTF-8') : strtolower($title);

            if (isset($titles[$key])) {
                $errors['dieule.' . $index . '.tieude'] = 'Tieu de dieu le bi trung.';
                continue;
            }

            $titles[$key] = true;
            $rules[] = [
                'tieude' => $title,
                'noidung' => $content,
                'filedinhkem' => $attachment,
            ];
        }

        if ($rules === [] && !isset($errors['dieule'])) {
            $errors['dieule'] = 'Can cung cap it nhat mot dieu le giai dau.';
        }

        return $rules;
    }

    private function isRuleObject(array $value): bool
    {
        return array_key_exists('tieude', $value)
            || array_key_exists('title', $value)
            || array_key_exists('noidung', $value)
            || array_key_exists('content', $value);
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

    private function withRules(int $tournamentId): ?array
    {
        $tournament = $this->tournaments->findById($tournamentId);

        if ($tournament === null) {
            return null;
        }

        $tournament['dieule'] = $this->tournaments->rulesForTournament($tournamentId);

        return $tournament;
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
