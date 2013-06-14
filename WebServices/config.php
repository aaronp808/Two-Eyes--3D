<?php

//
//  config.php
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

// Error Codes
const EC_TEMP_NOT_FOUND = 0;
const EC_FILE_EXISTS = 1;
const EC_CANT_MOVE_FILE = 2;
const EC_UNKNOWN = 3;

$config  =  array(
	'require_authorization'      =>  true,
	'base_upload_directory'      =>  realpath( '..' ) . '/data/results/',
	'base_upload_directory_mode' =>  0770,
	'allowed_file_pattern'       =>  '/\.(zip|tar|gz|txt)$/',
	'allowed_file_types'         =>  array( 'application/zip', 'application/octet-stream' ),
	'quiz_latest_version'        =>  '',
	'quiz_file_prefix'           =>  realpath( 'quizzes' ) . '/quiz_v',
);

function authenticate ( ) {
	if ( $config[ 'require_authorization' ] && ! isset( $_SERVER['PHP_AUTH_USER'] ) ) {
	    header('WWW-Authenticate: Basic realm="aavso"');
		header('HTTP/1.0 401 Unauthorized');
		echo('Unauthorized');
		exit();
	}
}