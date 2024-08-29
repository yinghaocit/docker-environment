<?php

/**
 * @file
 * Switch site.
 * @todo if the theme's drush alias is inconsistent with the warehouse and needs to be handled manually, getSiteRepoName() can be improved.
 */

$github_host = 'github.com';
$docroot = '/var/www/html/docroot';

$argv = $_SERVER['argv'];

$target_site = $argv[3];
if (empty($target_site)) {
  echo "Pleas type your site" . PHP_EOL;
  exit;
}
$target_site_repo = get_site_repo_name($target_site);

$settings_path = $docroot . '/sites/default/settings';

// 1. Update site id
if (file_exists($settings_path . '/default.local.siteInfo.php')) {
  $siteInfo = file_get_contents($settings_path . '/default.local.siteInfo.php');
}
else {
  echo "default.local.siteInfo.php not found in $settings_path";
  exit;
}

$siteInfo = str_replace('@siteId', $target_site, $siteInfo);
file_put_contents($settings_path . '/local.siteInfo.php', $siteInfo);

// 2. Sync database
// 2.1 Create database
echo "-------Create database-------" . PHP_EOL;
`drush sql:create --yes  --no-interaction --ansi`;
echo "-------Create database done-------" . PHP_EOL;

// 2.2 Sync database
echo "-------Sync database-------" . PHP_EOL;
`drush sql:sync @$target_site.01dev @self --yes  --no-interaction --ansi`;
echo "-------Sync database done-------" . PHP_EOL;

// 3. Sync theme
$themes_path = $docroot . '/themes/custom';
// 3.1 Theme is in CMAP repository
if (file_exists($themes_path . '/covermore_' . $target_site_repo)) {
  $theme_path = $themes_path . '/covermore_' . $target_site_repo;
}
elseif (file_exists($themes_path . '/' . $target_site_repo)) {
  $theme_path = $themes_path . '/' . $target_site_repo;
}

// 3.2 Theme is a independent repository
if (!isset($theme_path)) {
  $themes_path = '/var/www/themes';

  if (!file_exists($themes_path)) {
    echo "Please mount the themes directory in the same directory as cmap, '/var/www/themes'" . PHP_EOL;
    echo "Reference Documents [CMAP Project] https://sites.google.com/ciandt.com/cover-more-portal/architecture/onboarding-stuffs-new" . PHP_EOL;
    exit;
  }

  // Init theme.
  if (!file_exists($themes_path . '/' . $target_site_repo)) {
    $git = "git@{$github_host}:cdginteractive/{$target_site_repo}.git";
    `cd $themes_path && git clone $git && cd -`;
    // @todo If clone fails, you need to be prompted
  }
  // Delete the soft link to the original theme.
  if (file_exists($docroot . '/themes/custom/cmap_subtheme')) {
    `rm -rf $docroot/themes/custom/cmap_subtheme`;
  }

  // Theme path.
  $theme_path = $themes_path . '/' . $target_site_repo . '/cmap_subtheme';

  // Create theme link.
  `ln -s $theme_path $docroot/themes/custom/cmap_subtheme`;
}

if (!file_exists($theme_path)) {
  echo "{$theme_path} not found, try manual synchronization" . PHP_EOL;
  exit;
}

echo "-------Install theme-------" . PHP_EOL;
`cd $theme_path && npm install && npm run build && cd -`;
echo "-------Install theme done-------" . PHP_EOL;

echo "-------Clear cache-------" . PHP_EOL;
`drush cr --no-interaction --ansi`;
echo "-------Clear cache done-------" . PHP_EOL;

/**
 * Get site repo name.
 */
function get_site_repo_name($site) {

  $result = match ($site) {
    "budgetdirect" => "panda-theme",
    default => $site
  };

  return "theme-" . $result;
}
