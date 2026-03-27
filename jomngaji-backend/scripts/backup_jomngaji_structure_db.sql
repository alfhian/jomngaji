/*
SQLyog Ultimate v12.5.1 (64 bit)
MySQL - 10.4.32-MariaDB : Database - jomngaji
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
USE `jomngaji`;

/*Table structure for table `hijaiyah_evaluations` */

DROP TABLE IF EXISTS `hijaiyah_evaluations`;

CREATE TABLE `hijaiyah_evaluations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `lesson_id` int(11) NOT NULL,
  `hijaiyah` char(2) NOT NULL,
  `transcript` text DEFAULT NULL,
  `score_final` int(11) DEFAULT NULL,
  `score_audio` int(11) DEFAULT NULL,
  `score_ayat` int(11) DEFAULT NULL,
  `feedback` text DEFAULT NULL,
  `issues` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`issues`)),
  `evaluated_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_hijaiyah` (`user_id`,`hijaiyah`),
  KEY `idx_user_score` (`user_id`,`score_final`),
  CONSTRAINT `fk_hijaiyah_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=44 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Table structure for table `hijaiyah_lesson_unlocks` */

DROP TABLE IF EXISTS `hijaiyah_lesson_unlocks`;

CREATE TABLE `hijaiyah_lesson_unlocks` (
  `user_id` int(11) NOT NULL,
  `lesson_id` int(11) NOT NULL,
  `unlocked_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`user_id`,`lesson_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Table structure for table `hijaiyah_lessons` */

DROP TABLE IF EXISTS `hijaiyah_lessons`;

CREATE TABLE `hijaiyah_lessons` (
  `id` int(11) NOT NULL,
  `title` varchar(100) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `total_letters` int(11) NOT NULL,
  `order_index` int(11) NOT NULL,
  `is_premium` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Table structure for table `hijaiyah_letter_progress` */

DROP TABLE IF EXISTS `hijaiyah_letter_progress`;

CREATE TABLE `hijaiyah_letter_progress` (
  `user_id` int(11) NOT NULL,
  `lesson_id` int(11) NOT NULL,
  `hijaiyah` char(5) NOT NULL,
  `passed` tinyint(4) DEFAULT 0,
  `score` int(11) DEFAULT NULL,
  PRIMARY KEY (`user_id`,`lesson_id`,`hijaiyah`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Table structure for table `hijaiyah_progress` */

DROP TABLE IF EXISTS `hijaiyah_progress`;

CREATE TABLE `hijaiyah_progress` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `lesson_id` int(11) NOT NULL,
  `completed_letters` int(11) NOT NULL DEFAULT 0,
  `total_letters` int(11) NOT NULL,
  `average_score` float DEFAULT 0,
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_user` (`user_id`),
  UNIQUE KEY `uniq_user_lesson` (`user_id`,`lesson_id`),
  CONSTRAINT `fk_progress_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Table structure for table `iqra_exam_results` */

DROP TABLE IF EXISTS `iqra_exam_results`;

CREATE TABLE `iqra_exam_results` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `total_questions` int(11) NOT NULL,
  `correct_answers` int(11) NOT NULL,
  `pronunciation_avg_score` decimal(5,2) DEFAULT NULL,
  `pronunciation_question_count` int(11) DEFAULT NULL,
  `score` int(11) DEFAULT NULL,
  `final_score` decimal(5,2) DEFAULT NULL,
  `xp_earned` int(11) DEFAULT 0,
  `started_at` datetime DEFAULT NULL,
  `finished_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Table structure for table `quiz_attempts` */

DROP TABLE IF EXISTS `quiz_attempts`;

CREATE TABLE `quiz_attempts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `quiz_id` int(11) DEFAULT NULL,
  `correct` int(11) DEFAULT NULL,
  `total` int(11) DEFAULT NULL,
  `score` int(11) DEFAULT NULL,
  `xp` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=68 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Table structure for table `quiz_options` */

DROP TABLE IF EXISTS `quiz_options`;

CREATE TABLE `quiz_options` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `question_id` int(11) DEFAULT NULL,
  `option_text` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=158 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Table structure for table `quiz_questions` */

DROP TABLE IF EXISTS `quiz_questions`;

CREATE TABLE `quiz_questions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `quiz_id` int(11) DEFAULT NULL,
  `question_text` text NOT NULL,
  `correct_answer` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=65 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Table structure for table `quizzes` */

DROP TABLE IF EXISTS `quizzes`;

CREATE TABLE `quizzes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `quiz_code` varchar(100) NOT NULL,
  `quiz_type` varchar(50) NOT NULL,
  `title` varchar(200) NOT NULL,
  `xp_per_correct` int(11) DEFAULT 5,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `quiz_code` (`quiz_code`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Table structure for table `sessions` */

DROP TABLE IF EXISTS `sessions`;

CREATE TABLE `sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `token` varchar(255) DEFAULT NULL,
  `expires_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Table structure for table `subscriptions` */

DROP TABLE IF EXISTS `subscriptions`;

CREATE TABLE `subscriptions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `plan` varchar(50) NOT NULL,
  `status` varchar(20) NOT NULL,
  `start_date` date DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Table structure for table `suku_kata_level_unlocks` */

DROP TABLE IF EXISTS `suku_kata_level_unlocks`;

CREATE TABLE `suku_kata_level_unlocks` (
  `user_id` int(11) NOT NULL,
  `level_id` int(11) NOT NULL,
  `unlocked_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`user_id`,`level_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Table structure for table `suku_kata_levels` */

DROP TABLE IF EXISTS `suku_kata_levels`;

CREATE TABLE `suku_kata_levels` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(100) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `total_questions` int(11) DEFAULT 5,
  `order_index` int(11) NOT NULL,
  `is_premium` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Table structure for table `suku_kata_progress` */

DROP TABLE IF EXISTS `suku_kata_progress`;

CREATE TABLE `suku_kata_progress` (
  `user_id` int(11) NOT NULL,
  `level_id` int(11) NOT NULL,
  `completed_questions` int(11) DEFAULT 0,
  `average_score` float DEFAULT 0,
  PRIMARY KEY (`user_id`,`level_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Table structure for table `suku_kata_questions` */

DROP TABLE IF EXISTS `suku_kata_questions`;

CREATE TABLE `suku_kata_questions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `level_id` int(11) NOT NULL,
  `huruf` varchar(5) NOT NULL,
  `arabic` varchar(10) NOT NULL,
  `latin` varchar(10) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=133 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Table structure for table `tadarus_evaluations` */

DROP TABLE IF EXISTS `tadarus_evaluations`;

CREATE TABLE `tadarus_evaluations` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `surah` int(11) NOT NULL,
  `ayah` int(11) NOT NULL,
  `score_final` int(11) NOT NULL,
  `score_ayat` int(11) NOT NULL,
  `score_audio` int(11) NOT NULL,
  `asr_user` text DEFAULT NULL,
  `asr_ref` text DEFAULT NULL,
  `issues` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`issues`)),
  `suggestions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`suggestions`)),
  `evaluated_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_user_surah_ayah` (`user_id`,`surah`,`ayah`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Table structure for table `tadarus_progress` */

DROP TABLE IF EXISTS `tadarus_progress`;

CREATE TABLE `tadarus_progress` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `surah` int(11) NOT NULL,
  `total_ayah` int(11) NOT NULL,
  `completed_ayah` int(11) DEFAULT 0,
  `average_score` float DEFAULT 0,
  `last_ayah` int(11) DEFAULT NULL,
  `last_activity` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_user_surah` (`user_id`,`surah`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Table structure for table `tahfidz_evaluations` */

DROP TABLE IF EXISTS `tahfidz_evaluations`;

CREATE TABLE `tahfidz_evaluations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `lesson_id` int(11) NOT NULL,
  `transcript` text DEFAULT NULL,
  `score_final` int(11) DEFAULT NULL,
  `score_audio` int(11) DEFAULT NULL,
  `score_ayat` int(11) DEFAULT NULL,
  `feedback` text DEFAULT NULL,
  `issues` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`issues`)),
  `evaluated_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_tahfidz` (`user_id`,`lesson_id`),
  KEY `idx_user_score_tahfidz` (`user_id`,`score_final`),
  CONSTRAINT `fk_tahfidz_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Table structure for table `tahfidz_exam_results` */

DROP TABLE IF EXISTS `tahfidz_exam_results`;

CREATE TABLE `tahfidz_exam_results` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `total_questions` int(11) NOT NULL,
  `correct_answers` int(11) NOT NULL,
  `pronunciation_avg_score` decimal(5,2) DEFAULT NULL,
  `pronunciation_question_count` int(11) DEFAULT NULL,
  `score` int(11) DEFAULT NULL,
  `final_score` decimal(5,2) DEFAULT NULL,
  `xp_earned` int(11) DEFAULT NULL,
  `started_at` datetime DEFAULT NULL,
  `finished_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_tahfidz_exam_results_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Table structure for table `tajwid_evaluations` */

DROP TABLE IF EXISTS `tajwid_evaluations`;

CREATE TABLE `tajwid_evaluations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `lesson_id` int(11) NOT NULL,
  `transcript` text DEFAULT NULL,
  `score_final` int(11) DEFAULT NULL,
  `score_audio` int(11) DEFAULT NULL,
  `score_ayat` int(11) DEFAULT NULL,
  `feedback` text DEFAULT NULL,
  `issues` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`issues`)),
  `evaluated_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_tajwid` (`user_id`,`lesson_id`),
  KEY `idx_user_score` (`user_id`,`score_final`),
  CONSTRAINT `fk_tajwid_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Table structure for table `tajwid_exam_results` */

DROP TABLE IF EXISTS `tajwid_exam_results`;

CREATE TABLE `tajwid_exam_results` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `total_questions` int(11) NOT NULL,
  `correct_answers` int(11) NOT NULL,
  `pronunciation_avg_score` decimal(5,2) DEFAULT NULL,
  `pronunciation_question_count` int(11) DEFAULT NULL,
  `score` int(11) DEFAULT NULL,
  `final_score` decimal(5,2) DEFAULT NULL,
  `xp_earned` int(11) DEFAULT NULL,
  `started_at` datetime DEFAULT NULL,
  `finished_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_tajwid_exam_results_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Table structure for table `tilawah_evaluations` */

DROP TABLE IF EXISTS `tilawah_evaluations`;

CREATE TABLE `tilawah_evaluations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `lesson_id` int(11) NOT NULL,
  `transcript` text DEFAULT NULL,
  `score_final` int(11) DEFAULT NULL,
  `score_audio` int(11) DEFAULT NULL,
  `score_ayat` int(11) DEFAULT NULL,
  `feedback` text DEFAULT NULL,
  `issues` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`issues`)),
  `evaluated_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_tilawah` (`user_id`,`lesson_id`),
  KEY `idx_user_score_tilawah` (`user_id`,`score_final`),
  CONSTRAINT `fk_tilawah_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Table structure for table `tilawah_exam_results` */

DROP TABLE IF EXISTS `tilawah_exam_results`;

CREATE TABLE `tilawah_exam_results` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `total_questions` int(11) NOT NULL,
  `correct_answers` int(11) NOT NULL,
  `pronunciation_avg_score` decimal(5,2) DEFAULT NULL,
  `pronunciation_question_count` int(11) DEFAULT NULL,
  `score` int(11) DEFAULT NULL,
  `final_score` decimal(5,2) DEFAULT NULL,
  `xp_earned` int(11) DEFAULT NULL,
  `started_at` datetime DEFAULT NULL,
  `finished_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_tilawah_exam_results_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Table structure for table `user_progress` */

DROP TABLE IF EXISTS `user_progress`;

CREATE TABLE `user_progress` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `surah_number` int(11) DEFAULT NULL,
  `ayah_number` int(11) DEFAULT NULL,
  `progress` float DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Table structure for table `users` */

DROP TABLE IF EXISTS `users`;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `provider` varchar(20) DEFAULT 'local',
  `google_id` varchar(255) DEFAULT NULL,
  `avatar` text DEFAULT NULL,
  `is_premium` tinyint(1) DEFAULT 0,
  `premium_expired_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
