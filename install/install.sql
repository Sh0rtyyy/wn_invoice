CREATE TABLE IF NOT EXISTS `wn_billing` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `identifier` varchar(50) NOT NULL DEFAULT '0',
  `source_identifier` varchar(50) NOT NULL DEFAULT '0',
  `name` varchar(50) DEFAULT NULL,
  `source_name` varchar(50) DEFAULT NULL,
  `reason` text NOT NULL,
  `amount` int(11) NOT NULL DEFAULT 0,
  `job` varchar(50) NOT NULL DEFAULT '',
  `job_label` varchar(50) NOT NULL DEFAULT '',
  `date` varchar(50) NOT NULL DEFAULT '',
  `date_to_pay` varchar(50) NOT NULL DEFAULT '',
  `paid_date` varchar(50) NOT NULL DEFAULT '',
  `status` varchar(50) NOT NULL DEFAULT 'unpaid',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;