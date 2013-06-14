<?php

//
//  request_quiz.php
//  Two Eyes 3D
//
//  Created by Jerry Belich on 5/17/12.
//
//  Two Eyes, 3D is software for creating quizzes that capture user input as well as
//  timing data, and motion data.
//
//  Copyright (c) 2012-2013 AAVSO. All rights reserved.
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU Affero General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option) any
// later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more
// details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/.
//
// Also add information on how to contact you by electronic and paper mail.
//
// If your software can interact with users remotely through a computer network,
// you should also make sure that it provides a way for users to get its source.
// For example, if your program is a web application, its interface could
// display a “Source” link that leads users to an archive of the code.  There
// are many ways you could offer source, and different solutions will be better
// for different programs; see section 13 for the specific requirements.
//
// You should also get your employer (if you work as a programmer) or school, if
// any, to sign a “copyright disclaimer” for the program, if necessary.  For
// more information on this, and how to apply and follow the GNU AGPL, see
// http://www.gnu.org/licenses/.
//

require( 'config.php' );

header('Content-type: application/json');

/* Get quiz version number. */
if (isset($_POST['version'])) {
	$version = $_POST['version'];
	try {
		main( $version );
	}
	catch ( Exception $e ) {
		error( 'General API exception' );
	}
}
else {
	error( 'Version is required' );
}

function main ( $version ) {
	global $config;

	$latest_version  =  $config['quiz_latest_version'];

	if (version_compare($version, $latest_version, '<')) {
		$quiz_path = $config['quiz_file_prefix'] . $latest_version . ".json";
		$quiz_json = file_get_contents($quiz_path);
		
		if ($quiz_json === false) {
			/* Return JSON error message. */
			return error( 'Failed to load latest quiz v' . $latest_version );
		} else if (isJson($quiz_json) == false) {
			/* Return JSON error message. */
			return error( 'Quiz v' . $latest_version . ' contains invalid JSON data.' );
		}
		$json_arr = json_decode($quiz_json, true);
		$response = array('status' => 'success', 'version' => $latest_version, 'quiz' => $json_arr);
		echo json_encode($response);
	} else {
		/* Return JSON response, already has latest version. */
		$response = array('status' => 'success', 'version' => $latest_version);
		echo json_encode($response);
	}
}

function error ( $msg ) {
	global $config;
	$error  =  array( 'status' => 'error', 'version' => $config['quiz_latest_version'], 'error_msg' => $msg );
	echo json_encode( $error );
	exit();
}

function isJson($string) {
	json_decode($string);
	return (json_last_error() == JSON_ERROR_NONE);
}
