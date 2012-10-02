package OTRS::OPM::Maker;

use App::Cmd::Setup -app;

# ABSTRACT: Module/App to build and test OTRS packages

our $VERSION = 0.05;

=head1 DESCRIPTION

If you do OTRS package development, you need to be able to check your package: Are all files of the package included in the file list in the sopm file? Is the sopm file valid? And you need to create the OPM file. There is otrs.PackageManager.pl included in OTRS installations, but sometimes you might not have an OTRS installation on the machine where you want to build the package (e.g. when you build the package in a Jenkins (http://jenkins-ci.org) job).

C<OTRS::OPM::Maker> provides C<opmbuild> that is a small tool for several tasks. At the moment it supports:

=over 4

=item * filetest

Check if all files in the filelist exist on your disk and if all files on the disk are listed in the filelist

=item * somptest

Checks if your .sopm file is valid

=item * dependencies

List all CPAN- and OTRS- dependencies of your package

=item * build

Create the OPM file

=item * devlink

When you develop the package you might not want to build new version of your package and install it via the package manager. This command creates symlinks for each file of your package.

=item * devunlink

Remove the symlinks created with C<devlink>.

=item * index

build an index file for an OPM repository.

=back

Currently under development:

=over 4

=item * remote_install

Install the OPM file on any OTRS instance. That remote OTRS instance need an OTRS package installed (this is also under development)

=item * dbtest

Check if the C<DatabaseInstall> and C<DatabaseUninstall> sections in your .sopm files are valid. And it checks for SQL keywords.

=back

Ideas:

=over 4

=item * devdb

Do the DB changes needed for your package

=back

=cut

1;
