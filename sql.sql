-- phpMyAdmin SQL Dump
-- version 4.9.0.1
-- https://www.phpmyadmin.net/
--
-- Värd: 127.0.0.1
-- Tid vid skapande: 10 jun 2020 kl 22:49
-- Serverversion: 10.4.6-MariaDB
-- PHP-version: 7.3.9

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

-- --------------------------------------------------------

--
-- Tabellstruktur `aktieagare`
--

CREATE TABLE `aktieagare` (
  `id` int(255) NOT NULL,
  `identifier` varchar(255) NOT NULL,
  `namn` varchar(255) NOT NULL,
  `aktier` int(11) NOT NULL,
  `foretag` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellstruktur `aktiebank`
--

CREATE TABLE `aktiebank` (
  `id` int(11) NOT NULL,
  `identifier` varchar(255) NOT NULL,
  `bank` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tabellstruktur `aktiesalj`
--

CREATE TABLE `aktiesalj` (
  `id` int(11) NOT NULL,
  `sidentifier` varchar(255) NOT NULL,
  `saljarnamn` varchar(255) NOT NULL,
  `mangd` int(10) NOT NULL,
  `pris` float NOT NULL,
  `foretag` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Index för dumpade tabeller
--

--
-- Index för tabell `aktieagare`
--
ALTER TABLE `aktieagare`
  ADD PRIMARY KEY (`id`);

--
-- Index för tabell `aktiebank`
--
ALTER TABLE `aktiebank`
  ADD PRIMARY KEY (`id`);

--
-- Index för tabell `aktiesalj`
--
ALTER TABLE `aktiesalj`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT för dumpade tabeller
--

--
-- AUTO_INCREMENT för tabell `aktieagare`
--
ALTER TABLE `aktieagare`
  MODIFY `id` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT för tabell `aktiebank`
--
ALTER TABLE `aktiebank`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT för tabell `aktiesalj`
--
ALTER TABLE `aktiesalj`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=95;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
