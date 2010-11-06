package Module::Flavor::Template::Module;
1;

=head1

Module::Flavor::Template::Module - default module flavor

=head1 SYNOPSIS


=cut

__DATA__
---
file: Makefile.PL
template: |
  use inc::Module::Install;
  name '[% dist %]';
  all_from 'lib/[% path %]';

  requires(

  );
  test_requires(
      'Test::More'  => 0.88,
  );
  use_test_base;
  auto_include;
  WriteAll;

---
file: t/00_compile.t
template: |
  use strict;
  use Test::More tests => 1;
  
  BEGIN { use_ok '[% module %]' }

---
file: xt/extra/dependency.t
template: |
  use Test::Dependencies
      exclude => [qw/Test::Dependencies Test::Base Test::Perl::Critic [% module %]/],
      style   => 'light';
  ok_dependencies();

---
file: xt/extra/podspell.t
template: |
  use Test::More;
  eval q{ use Test::Spelling };
  plan skip_all => "Test::Spelling is not installed." if $@;
  add_stopwords(map { split /[\s\:\-]/ } <DATA>);
  $ENV{LANG} = 'C';
  set_spell_cmd("aspell list");
  all_pod_files_spelling_ok('lib');
  __DATA__
  [% config.author %]
  [% module %]
---
file: xt/perlcritic.t
template: |
  use strict;
  use Test::More;
  eval { use Test::Perl::Critic -profile => 'xt/perlcriticrc' };
  plan skip_all => "Test::Perl::Critic is not installed." if $@;
  all_critic_ok('lib');
---
file: xt/pod.t
template: |
  use Test::More;
  eval "use Test::Pod 1.00";
  plan skip_all => "Test::Pod 1.00 required for testing POD" if $@;
  all_pod_files_ok();

---
file: xt/notab.t
template: |
  use Test::More;
  eval "use Test::NoTabs";
  plan skip_all => "Test::NoTabs required for testing POD" if $@;
  all_perl_files_ok();
---
file: xt/perlcriticrc
template: |
  [TestingAndDebugging::ProhibitNoStrict]
  allow=refs
  [TestingAndDebugging::RequireUseStrict]
  equivalent_modules = Mouse Mouse::Role 

---
file: Changes
template: |
  Revision history for Perl extension [% module %]

  0.01 [% localtime %]
  	* original version
---
file: lib/$path
template: |
  package [% module %];

  use strict;
  use warnings;
  our $VERSION = '0.01';

  1;
  __END__

  =encoding utf-8

  =head1 NAME

  [% module %] -

  =head1 SYNOPSIS

    use [% module %];

  =head1 DESCRIPTION

  [% module %] is

  =head1 CONTRIBUTORS

  Many thanks to:


  =head1 AUTHOR

  [% config.author %] E<lt>[% config.email %]E<gt>

  =head1 SEE ALSO

  =head1 LICENSE

  This library is free software; you can redistribute it and/or modify
  it under the same terms as Perl itself.

  =cut
---
file: MANIFEST.SKIP
template: |
  \bRCS\b
  \bCVS\b
  ^MANIFEST\.
  ^Makefile$
  ~$
  ^#
  \.old$
  ^blib/
  ^pm_to_blib
  ^MakeMaker-\d
  \.gz$
  \.cvsignore
  ^t/9\d_.*\.t
  ^t/perlcritic
  ^xt/
  ^tools/
  \.svn/
  \.git/
  ^[^/]+\.yaml$
  ^[^/]+\.pl$
  ^\.shipit$
---
file: README
template: |
  This is Perl module [% module %].

  INSTALLATION

  [% module %] installation is straightforward. If your CPAN shell is set up,
  you should just be able to do

      % cpan [% module %]

  Download it, unpack it, then build it as per the usual:

      % perl Makefile.PL
      % make && make test

  Then install it:

      % make install

  DOCUMENTATION

  [% module %] documentation is available as in POD. So you can do:

      % perldoc [% module %]

  to read the documentation online with your favorite pager.

  [% config.author %]
---
file: .shipit
chmod: 0644
template: |
  steps = FindVersion, ChangeVersion, CheckChangeLog, DistTest, Commit, Tag, MakeDist, UploadCPAN
  git.tagpattern = release-%v
  git.push_to = origin

---
file: .gitignore
template: |
  cover_db
  META.yml
  Makefile
  blib
  inc
  pm_to_blib
  MANIFEST
  MANIFEST.bak
  Makefile.old
  tmon.out
  cover_db_view
  nytprof
  .DS_Store
