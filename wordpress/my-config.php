<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://codex.wordpress.org/Editing_wp-config.php
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'acloudguru' );

/** MySQL database username */
define( 'DB_USER', 'acloudguru' );

/** MySQL database password */
define( 'DB_PASSWORD', 'acloudguru' );

/** MySQL hostname */
define( 'DB_HOST', 'terraform-20210424222828455700000001.cjdnc7qhdz0k.us-west-2.rds.amazonaws.com' );

/** Database Charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8mb4' );

/** The Database Collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',         '%E2V#_E{OVAPACpHX eXhC`{G`Ymw;M-=k?,ysjzBKZ$S NugQ4o,Z$2#ZdI~<VM' );
define( 'SECURE_AUTH_KEY',  '#77bd_R76B/U0Pf+`usQ3pi)9$sem91L$gj^X[%h_ou$Ys80gn`ld&dv*dz5Df8~' );
define( 'LOGGED_IN_KEY',    'CTygkX#jkRsgXsO_a][,}Fb|4G(.GdU<3q+PVUj0_>Za8LBER[G*d<9;{qGk.=,5' );
define( 'NONCE_KEY',        '|;-3]-N}2d_7FIY8JsU%/z|9iQx%k7vj:nbavOZInwcPpW`9nRTE`9)7T*!8COu~' );
define( 'AUTH_SALT',        '.q(6_,6e;{RP;HpuE2dK s:un26wsrK#V5Zv%)T-0;O]mJ-M]Av+w0Yd)o2Z/ZHF' );
define( 'SECURE_AUTH_SALT', 'a0( e+@dSU;q;6}kH3/VUR*f0F$w.V&$Uhc=%eDZa8MWHjbdKSi6[^U)JHCB--u>' );
define( 'LOGGED_IN_SALT',   'qHHeX:hWK%6)_Mq3&#0@3THf+jzo*%pBr}*6Ls8z3:vH%!9`R@A<75c}?gfKs!s(' );
define( 'NONCE_SALT',       '4+Ufrnw*kWemZ:>V sC0 0WpCh#O`e%E;`)2<`n`Pxe1>~8|~{7JGBQQeSeHxBSN' );

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the Codex.
 *
 * @link https://codex.wordpress.org/Debugging_in_WordPress
 */
define( 'WP_DEBUG', false );

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', dirname( __FILE__ ) . '/' );
}

/** Sets up WordPress vars and included files. */
require_once( ABSPATH . 'wp-settings.php' );
