<?php

//
//  list_results.php
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

# @todo: sort by date, add kill switch
require( 'config.php' );

try {
	$dirs  =  build_directory_map( );
}
catch ( Exception $e ) {
	$dirs  =  array( );
}

function sort_file_by_date ( $a, $b ) {
	return filemtime( $a ) - filemtime( $b );
}

function build_directory_map ( ) {
	global $config;

	$dirs           =  array( );
	$ignored_paths  =  array( '.', '..' );
	$dir_names      =  array_diff( scandir( $config['base_upload_directory'] ), $ignored_paths );

	foreach ( $dir_names as $dir_name ) {

		$dir_path  =  $config['base_upload_directory'] . $dir_name . '/';
		$children  =  scandir( $dir_path );
		$children  =  array_diff( $children, $ignored_paths );

		$sorter    =  function ( $a, $b ) use ( $dir_path ) {
			return filemtime( $dir_path . $a ) - filemtime( $dir_path . $b );
		};
		usort( $children, $sorter );

		$files     =  array( );

		foreach ( $children as $child_name ) {
			$files[]  =  array( 
				'time'   => date( 'h:i:s a', filemtime( $dir_path . $child_name ) ),
				'folder' => $dir_name,
				'name'   => $child_name,
			);
		}

		$dirs[]  =  array(
			'name'   =>  $dir_name,
			'files'  =>  $files,
		);
	}

	return $dirs;
}
?>
<html>
	<head><title>AAVSO 2-Eyes, 3-D Results</title></head>
	<body>
		<?php foreach ( $dirs as $dir ) { ?>
		<h2><?php echo $dir[ 'name' ]; ?></h2>
		<ol>
			<?php foreach ( $dir[ 'files' ] as $file ) { ?>
			<li><?php echo $file[ 'time' ] ?> <a target="_new" href="get_file.php?f=<?php echo $file[ 'name' ] ?>&d=<?php echo $file[ 'folder' ] ?>"><?php echo $file[ 'name' ]; ?></a></li>
			<?php } ?>
		</ol>
		<?php } ?>
	</body>
</html>
