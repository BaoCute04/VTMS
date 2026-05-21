<?php

declare(strict_types=1);

namespace App\Backend\Services\Organizer;

use App\Backend\Models\Giaidau;
use App\Backend\Models\Tucachthamgia;
use Throwable;

final class OrganizerHigherEligibilityService
{
    public function __construct(
        private ?Giaidau $tournaments = null,
        private ?Tucachthamgia $eligibility = null
    ) {
        $this->tournaments ??= new Giaidau();
        $this->eligibility ??= new Tucachthamgia();
    }

    public function overview(int $accountId, array $filters = []): array
    {
        $organizer = $this->activeOrganizer($accountId);

        if (isset($organizer['ok']) && $organizer['ok'] === false) {
            return $organizer;
        }

        $normalized = $this->filters($filters);

        return [
            'ok' => true,
            'status' => 200,
            'message' => 'Lay danh sach de cu tu cach tham gia thanh cong.',
            'data' => [
                'candidates' => $this->eligibility->candidatesForOrganizer((int) $organizer['idbantochuc'], $normalized),
                'incoming' => $this->eligibility->incomingForOrganizer((int) $organizer['idbantochuc'], $normalized),
            ],
            'meta' => [
                'filters' => $normalized,
                'organizer' => [
                    'idbantochuc' => (int) $organizer['idbantochuc'],
                    'donvi' => (string) $organizer['donvi'],
                    'capkhuvucquanly' => (string) $organizer['capkhuvucquanly'],
                ],
            ],
        ];
    }

    public function markEligible(array $payload, int $accountId): array
    {
        $organizer = $this->activeOrganizer($accountId);

        if (isset($organizer['ok']) && $organizer['ok'] === false) {
            return $organizer;
        }

        [$achievementId, $targetTournamentId, $note, $errors] = $this->candidatePayload($payload);

        if ($errors !== []) {
            return $this->failure('Du lieu danh dau tu cach khong hop le.', 422, $errors);
        }

        $candidate = $this->eligibility->candidate($achievementId, $targetTournamentId, (int) $organizer['idbantochuc']);

        if ($candidate === null) {
            return $this->failure('Khong tim thay doi vo dich phu hop de xet tu cach.', 404);
        }

        try {
            $proposalId = $this->eligibility->markEligible($candidate, $accountId, $note);

            return [
                'ok' => true,
                'status' => 200,
                'message' => 'Da danh dau doi bong du dieu kien de cu len cap cao hon.',
                'proposal_id' => $proposalId,
            ];
        } catch (Throwable) {
            return $this->failure('Khong the danh dau tu cach tham gia.', 500);
        }
    }

    public function nominate(int $proposalId, array $payload, int $accountId): array
    {
        $organizer = $this->activeOrganizer($accountId);

        if (isset($organizer['ok']) && $organizer['ok'] === false) {
            return $organizer;
        }

        if ($proposalId <= 0) {
            return $this->failure('De cu khong hop le.', 422);
        }

        try {
            $updated = $this->eligibility->nominate(
                $proposalId,
                (int) $organizer['idbantochuc'],
                $accountId,
                $this->note($payload)
            );

            if (!$updated) {
                return $this->failure('Chi duoc de cu doi da duoc danh dau du dieu kien.', 409);
            }

            return [
                'ok' => true,
                'status' => 200,
                'message' => 'Da gui de cu len ban to chuc cap cao hon.',
            ];
        } catch (Throwable) {
            return $this->failure('Khong the gui de cu.', 500);
        }
    }

    public function approve(int $proposalId, array $payload, int $accountId): array
    {
        return $this->decide($proposalId, $payload, $accountId, true);
    }

    public function reject(int $proposalId, array $payload, int $accountId): array
    {
        return $this->decide($proposalId, $payload, $accountId, false);
    }

    private function decide(int $proposalId, array $payload, int $accountId, bool $approved): array
    {
        $organizer = $this->activeOrganizer($accountId);

        if (isset($organizer['ok']) && $organizer['ok'] === false) {
            return $organizer;
        }

        if ($proposalId <= 0) {
            return $this->failure('De cu khong hop le.', 422);
        }

        $note = $this->note($payload);

        if (!$approved && $note === null) {
            return $this->failure('Can nhap ly do tu choi de cu.', 422, [
                'lydo' => 'Ly do tu choi la bat buoc.',
            ]);
        }

        try {
            $updated = $this->eligibility->decide(
                $proposalId,
                (int) $organizer['idbantochuc'],
                $accountId,
                $approved,
                $note
            );

            if (!$updated) {
                return $this->failure('Chi duoc xu ly de cu dang cho xac nhan va thuoc quyen BTC hien tai.', 409);
            }

            return [
                'ok' => true,
                'status' => 200,
                'message' => $approved
                    ? 'Da xac nhan de cu, doi bong co tu cach tham gia giai cap cao hon.'
                    : 'Da tu choi de cu tu cach tham gia.',
            ];
        } catch (Throwable) {
            return $this->failure('Khong the xu ly de cu tu cach tham gia.', 500);
        }
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

    private function filters(array $filters): array
    {
        return [
            'q' => trim((string) ($filters['q'] ?? '')),
        ];
    }

    private function candidatePayload(array $payload): array
    {
        $achievementRaw = $payload['idthanhtich'] ?? $payload['achievement_id'] ?? null;
        $targetRaw = $payload['idgiaidau_dich'] ?? $payload['target_tournament_id'] ?? null;
        $errors = [];

        if ($achievementRaw === null || !ctype_digit((string) $achievementRaw) || (int) $achievementRaw <= 0) {
            $errors['idthanhtich'] = 'Thanh tich khong hop le.';
        }

        if ($targetRaw === null || !ctype_digit((string) $targetRaw) || (int) $targetRaw <= 0) {
            $errors['idgiaidau_dich'] = 'Giai dau cap cao hon khong hop le.';
        }

        return [
            (int) $achievementRaw,
            (int) $targetRaw,
            $this->note($payload),
            $errors,
        ];
    }

    private function note(array $payload): ?string
    {
        $note = trim((string) ($payload['lydo'] ?? $payload['note'] ?? $payload['ghichu'] ?? ''));

        if ($note === '') {
            return null;
        }

        return strlen($note) > 1000 ? substr($note, 0, 1000) : $note;
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
