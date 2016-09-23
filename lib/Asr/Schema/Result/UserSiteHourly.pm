package Asr::Schema::Result::UserSiteHourly;

use Modern::Perl;
use base 'DBIx::Class::Core';

use Data::FormValidator;

__PACKAGE__->load_components(qw/
   Helper::Row::ToJSON
   InflateColumn::DateTime
/);

__PACKAGE__->table('user_site_hourly');
__PACKAGE__->add_columns(
   'id' => {
      data_type => 'bigint',
      is_auto_increment => 1,
      is_nullable => 0
   },
   'local_time' => {
      data_type => 'timestamp',
      is_nullable => 0
   },
   'remote_user' => {
      data_type => 'varchar',
      is_nullable => 0
   },
   'site' => {
      data_type => 'varchar',
      is_nullable => 0,
   },
   'total_time' => {
      data_type => 'bigint',
      is_nullable => 0
   },
   'total_bytes' => {
      data_type => 'bigint',
      is_nullable => 0
   }
);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(tag => 'Asr::Schema::Result::Tag', {'foreign.id' => 'self.tag_id'});

1;
