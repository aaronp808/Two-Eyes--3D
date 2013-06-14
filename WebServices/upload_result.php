<?php

//
//  upload_result.php
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

if (isset($_FILES['result']) && isset($_POST['checksum'])) {
	$result    =  $_FILES['result'];
	$checksum  =  $_POST['checksum'];

	try {
		verify_file( $result, $checksum );
		upload( $result );
	}
	catch ( Exception $e ) {
		error( 'General API exception' );
	}
}
else {
	error( 'A file and checksum are required' );
}


function verify_file ( $file, $checksum ) {
	global $config;

	if ( $file['size'] === 0 ) {
		error( "Empty file" );
	}
	if ( ! in_array( $file['type'], $config['allowed_file_types'] ) ) {
		error( "Invalid file type '{$file['type']}'" );
	}

	$path  =  $file['tmp_name'];
	$md5   =  md5_file( $path );

	if ( $checksum !== $md5 ) {
		error( "Checksum mismatch" );
	}
}


function upload ( $file ) {
	$tmp_path     =  $file['tmp_name'];
	$name         =  $file['name'];
	$dir          =  ensure_directory( );
	$upload_path  =  $dir . '/' . $name;

	$error_msg    =  "";
	$error_code   =  EC_UNKNOWN;

	if ( ! is_file( $tmp_path ) ) {
		$error_msg  =  "Temp file not found";
		$error_code = EC_TEMP_NOT_FOUND;
	}
	else if ( is_file( $upload_path ) ) {
		$error_msg  =  "File already exists";
		$error_code = EC_FILE_EXISTS;
	}
	else if ( ! move_uploaded_file( $tmp_path, $upload_path ) ) {
		$error_msg  =  "Error moving uploaded file `$tmp_path` to `$upload_path`";
		$error_code = EC_CANT_MOVE_FILE;
	}
	else {
		echo( json_encode( array( 'status' => 'success' ) ) );
		exit(0);
	}

	$error_path  =  "{$dir}/error_{$name}.txt";
	if ( ! file_put_contents( $error_path, date('c' ) . " - {$name}: {$error_msg}\n", FILE_APPEND ) ) {
		$error_msg  .=  ". Also: error saving error message";
	}
	error( $error_msg, $error_code );
}


function ensure_directory ( ) {
	global $config;
	$date  =  date( 'Y-m-d' );
	$dir   =  $config['base_upload_directory'] . $date;
	if ( ! is_dir( $dir ) ) {
		if ( ! mkdir( $dir, $config['base_upload_directory_mode'] ) ) {
			error( "Could not make directory '$dir'" );
		}
	}
	return $dir;
}


function error ( $msg, $code ) {
	$error  =  array( 'status' => 'error', 'error_msg' => $msg, 'error_code' => $code );
	echo json_encode( $error );
	exit(0);
}
