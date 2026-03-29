-- ============================================================
-- Migration: Unify module evaluation tables into learning_evaluations
-- Scope    : tajwid_evaluations, tilawah_evaluations,
--            tahfidz_evaluations, tadarus_evaluations
-- ============================================================

-- =========================
-- UP
-- =========================
CREATE TABLE IF NOT EXISTS `learning_evaluations` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `feature_type` ENUM('iqra','tajwid','tilawah','tahfidz','tadarus') NOT NULL,
  `lesson_id` INT DEFAULT NULL,
  `surah` INT DEFAULT NULL,
  `ayah` INT DEFAULT NULL,
  `transcript` TEXT DEFAULT NULL,
  `score_final` INT DEFAULT NULL,
  `score_audio` INT DEFAULT NULL,
  `score_ayat` INT DEFAULT NULL,
  `feedback` TEXT DEFAULT NULL,
  `asr_user` TEXT DEFAULT NULL,
  `asr_ref` TEXT DEFAULT NULL,
  `issues` JSON DEFAULT NULL,
  `suggestions` JSON DEFAULT NULL,
  `evaluated_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_learning_eval_user_feature` (`user_id`,`feature_type`),
  KEY `idx_learning_eval_user_feature_lesson` (`user_id`,`feature_type`,`lesson_id`),
  KEY `idx_learning_eval_user_feature_surah_ayah` (`user_id`,`feature_type`,`surah`,`ayah`),
  KEY `idx_learning_eval_user_feature_score` (`user_id`,`feature_type`,`score_final`),
  UNIQUE KEY `uniq_learning_eval_tadarus` (`user_id`,`feature_type`,`surah`,`ayah`,`lesson_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `learning_evaluations`
(`user_id`,`feature_type`,`lesson_id`,`transcript`,`score_final`,`score_audio`,`score_ayat`,`feedback`,`issues`,`evaluated_at`,`updated_at`)
SELECT
  `user_id`, 'tajwid', `lesson_id`, `transcript`, `score_final`, `score_audio`, `score_ayat`, `feedback`, `issues`, `evaluated_at`, `updated_at`
FROM `tajwid_evaluations`;

INSERT INTO `learning_evaluations`
(`user_id`,`feature_type`,`lesson_id`,`transcript`,`score_final`,`score_audio`,`score_ayat`,`feedback`,`issues`,`evaluated_at`,`updated_at`)
SELECT
  `user_id`, 'tilawah', `lesson_id`, `transcript`, `score_final`, `score_audio`, `score_ayat`, `feedback`, `issues`, `evaluated_at`, `updated_at`
FROM `tilawah_evaluations`;

INSERT INTO `learning_evaluations`
(`user_id`,`feature_type`,`lesson_id`,`transcript`,`score_final`,`score_audio`,`score_ayat`,`feedback`,`issues`,`evaluated_at`,`updated_at`)
SELECT
  `user_id`, 'tahfidz', `lesson_id`, `transcript`, `score_final`, `score_audio`, `score_ayat`, `feedback`, `issues`, `evaluated_at`, `updated_at`
FROM `tahfidz_evaluations`;

INSERT INTO `learning_evaluations`
(`user_id`,`feature_type`,`surah`,`ayah`,`score_final`,`score_audio`,`score_ayat`,`asr_user`,`asr_ref`,`issues`,`suggestions`,`evaluated_at`,`updated_at`)
SELECT
  `user_id`, 'tadarus', `surah`, `ayah`, `score_final`, `score_audio`, `score_ayat`, `asr_user`, `asr_ref`, `issues`, `suggestions`, `evaluated_at`, `updated_at`
FROM `tadarus_evaluations`;

-- =========================
-- DOWN
-- =========================
-- NOTE: This down migration restores data into original tables
--       and then drops learning_evaluations.

DELETE FROM `tajwid_evaluations`;
INSERT INTO `tajwid_evaluations`
(`user_id`,`lesson_id`,`transcript`,`score_final`,`score_audio`,`score_ayat`,`feedback`,`issues`,`evaluated_at`,`updated_at`)
SELECT
  `user_id`, `lesson_id`, `transcript`, `score_final`, `score_audio`, `score_ayat`, `feedback`, `issues`, `evaluated_at`, `updated_at`
FROM `learning_evaluations`
WHERE `feature_type` = 'tajwid';

DELETE FROM `tilawah_evaluations`;
INSERT INTO `tilawah_evaluations`
(`user_id`,`lesson_id`,`transcript`,`score_final`,`score_audio`,`score_ayat`,`feedback`,`issues`,`evaluated_at`,`updated_at`)
SELECT
  `user_id`, `lesson_id`, `transcript`, `score_final`, `score_audio`, `score_ayat`, `feedback`, `issues`, `evaluated_at`, `updated_at`
FROM `learning_evaluations`
WHERE `feature_type` = 'tilawah';

DELETE FROM `tahfidz_evaluations`;
INSERT INTO `tahfidz_evaluations`
(`user_id`,`lesson_id`,`transcript`,`score_final`,`score_audio`,`score_ayat`,`feedback`,`issues`,`evaluated_at`,`updated_at`)
SELECT
  `user_id`, `lesson_id`, `transcript`, `score_final`, `score_audio`, `score_ayat`, `feedback`, `issues`, `evaluated_at`, `updated_at`
FROM `learning_evaluations`
WHERE `feature_type` = 'tahfidz';

DELETE FROM `tadarus_evaluations`;
INSERT INTO `tadarus_evaluations`
(`user_id`,`surah`,`ayah`,`score_final`,`score_ayat`,`score_audio`,`asr_user`,`asr_ref`,`issues`,`suggestions`,`evaluated_at`,`updated_at`)
SELECT
  `user_id`, `surah`, `ayah`, `score_final`, `score_ayat`, `score_audio`, `asr_user`, `asr_ref`, `issues`, `suggestions`, `evaluated_at`, `updated_at`
FROM `learning_evaluations`
WHERE `feature_type` = 'tadarus';

DROP TABLE IF EXISTS `learning_evaluations`;
