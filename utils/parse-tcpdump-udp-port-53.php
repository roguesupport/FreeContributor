<?php

// quick and dirty argument parsing
foreach ($argv as $arg) {
    if ($arg == '-f') {
        define('FOLLOW', true);
    }
    if ($arg == '-h') {
        define('HISTOGRAM', true);
    }
}
if (!defined('FOLLOW')) {
    define('FOLLOW', false);
}
if (!defined('HISTOGRAM')) {
    define('HISTOGRAM', false);
}

$queries = array();
$output = array();

while (!feof(STDIN)) {
    $line = fgets(STDIN, 8192);

    if (!preg_match('/^\d{2}:\d{2}:\d{2}\.\d+ IP [^>]+ > .+/', $line)) {
        $line .= fgets(STDIN, 8192);
    }

    // query
    if (preg_match('/^(\d{2}:\d{2}:\d{2}\.\d+) IP [^>]+ > .+ (\d+)\+ (A(AAA)?)\? ([^ ]+)/', $line, $regs)) {
        $qtimestamp = $regs[1];
        $id = $regs[2];
        $qtype = $regs[3];
        $qsubject = rtrim($regs[5], '.');

        $queries[$id] = array($qtimestamp, $qtype, $qsubject);
    } else

    // response
    if (preg_match('/^(\d{2}:\d{2}:\d{2}\.\d+) IP [^>]+ > .+ (\d+).? q: (A(AAA)?)\? ([^ ]+)/', $line, $regs)) {
        $rtimestamp = $regs[1];
        $id = $regs[2];
        $rtype = $regs[3];
        $rsubject = rtrim($regs[5], '.');

        if (isset($queries[$id])) {
            list ($qtimestamp, $qtype, $qsubject) = $queries[$id];
            if ($rtype == $qtype && $qsubject == $rsubject) {
                $ms = (parse_timestamp($rtimestamp) - parse_timestamp($qtimestamp)) * 1000;
                $bangs = max(0, ceil(log10($ms)));
                output($qtimestamp, sprintf(
                    "%- 4s %- 50s % 8.03f ms%s",
                    $qtype, $qsubject, $ms, $bangs ? ' ' . str_repeat('!', $bangs) : ''
                ));
            } else {
                output($qtimestamp, sprintf(
                    "got response for query %s, but query type or subject don't match, query was %s %s, response was %s %s",
                    $id, $qtype, $qsubject, $rtype, $rsubject
                ));
            }
        } else {
            output($rtimestamp, sprintf(
                "got response to unsolicited %s query for %s (query %s)",
                $rtype, $rsubject, $id
            ));
        }

        unset($queries[$id]);
    }
}
fclose(STDIN);

if (!FOLLOW) {
    // look for queries without responses
    foreach ($queries as $id => $query) {
        list ($qtimestamp, $qtype, $qsubject) = $query;
        output($qtimestamp, sprintf(
            "%- 4s %- 50s        - ms **********",
            $qtype, $qsubject
        ));
    }

    // collate buffered output
    foreach ($output as $hm => $bucket) {
        ksort($bucket);
        foreach ($bucket as $sa => $data) {
            list($timestamp, $message) = $data;
            output_real($timestamp, $message);
        }
    }

    // print histogram data
    if (HISTOGRAM) {
        echo "\n\n\n";
        foreach ($output as $hm => $bucket) {
            // count failed queries
            $failed = 0;
            foreach ($bucket as $sa => $data) {
                list($timestamp, $message) = $data;
                if (strpos($message, '- ms **********') !== false) {
                    $failed++;
                }
            }

            printf("%s,%d\n", $hm, $failed);
        }
    }
}

function output($timestamp, $message)
{
    if (FOLLOW) {
        output_real($timestamp, $message);
        flush();
    } else {
        // buffer output
        $hm = substr($timestamp, 0, 5);
        $sa = substr($timestamp, 6);

        global $output;
        $output[$hm][$sa] = array($timestamp, $message);
    }
}

function output_real($timestamp, $message)
{
    printf("%s %s\n", $timestamp, $message);
}

function parse_timestamp($timestamp)
{
    $hours = substr($timestamp, 0, 2);
    $minutes = substr($timestamp, 3, 2);
    $seconds = substr($timestamp, 6, 2);
    $after = substr($timestamp, 9);
    return $hours * 3600 + $minutes * 60 + $seconds + (float) ('0.'.$after);
}
