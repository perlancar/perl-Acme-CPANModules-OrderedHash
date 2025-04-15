package Acme::CPANModules::OrderedHash;

use strict;

# AUTHORITY
# DATE
# DIST
# VERSION

our $LIST = {
    summary => "List of modules that provide ordered hash data type",
    description => <<'MARKDOWN',

When you ask a Perl's hash for the list of keys, the answer comes back
unordered. In fact, Perl explicitly randomizes the order of keys it returns
everytime. The random ordering is a (security) feature, not a bug. However,
sometimes you want to know the order of insertion. These modules provide you
with an ordered hash; most of them implement it by recording the order of
insertion of keys in an additional array.

Other related modules:

<pm:Tie::SortHash> - will automatically sort keys when you call `keys()`,
`values()`, `each()`. But this module does not maintain insertion order.

MARKDOWN
    entries => [

        {
            module => 'Tie::IxHash',
            bench_code => sub {
                my ($op, $numkeys, $numrep) = @_;

                tie my %hash, "Tie::IxHash";
                for (1..$numkeys) { $hash{"key$_"} = $_ }

                if ($op eq 'delete') {
                    for (1..$numkeys) { delete $hash{"key$_"} }
                } elsif ($op eq 'keys') {
                    for (1..$numrep) { my @keys = keys %hash }
                } elsif ($op eq 'iterate') {
                    for (1..$numrep) { while (my ($k,$v) = each %hash) {} }
                }
            },
        },

        {
            module => 'Hash::Ordered',
            bench_code => sub {
                my ($op, $numkeys, $numrep) = @_;

                my $hash = Hash::Ordered->new;
                for (1..$numkeys) { $hash->set("key$_" => $_) }

                if ($op eq 'delete') {
                    for (1..$numkeys) { $hash->delete("key$_") }
                } elsif ($op eq 'keys') {
                    for (1..$numrep) { my @keys = $hash->keys }
                } elsif ($op eq 'iterate') {
                    for (1..$numrep) { my $iter = $hash->iterator; while (my ($k,$v) = $iter->()) {} }
                }
            },
        },

        {
            module => 'Tie::Hash::Indexed',
            description => <<'MARKDOWN',

Provides two interfaces: tied hash and OO.

MARKDOWN
            bench_code => sub {
                my ($op, $numkeys, $numrep) = @_;

                tie my %hash, "Tie::Hash::Indexed";
                for (1..$numkeys) { $hash{"key$_"} = $_ }

                if ($op eq 'delete') {
                    for (1..$numkeys) { delete $hash{"key$_"} }
                } elsif ($op eq 'keys') {
                    for (1..$numrep) { my @keys = keys %hash }
                } elsif ($op eq 'iterate') {
                    for (1..$numrep) { while (my ($k,$v) = each %hash) {} }
                }
            },
        },

        {
            module => 'Tie::LLHash',
            bench_code => sub {
                my ($op, $numkeys, $numrep) = @_;

                tie my %hash, "Tie::LLHash";
                for (1..$numkeys) { (tied %hash)->insert("key$_" => $_) }

                if ($op eq 'delete') {
                    for (1..$numkeys) { delete $hash{"key$_"} }
                } elsif ($op eq 'keys') {
                    for (1..$numrep) { my @keys = keys %hash }
                } elsif ($op eq 'iterate') {
                    for (1..$numrep) { while (my ($k,$v) = each %hash) {} }
                }
            },
        },

        {
            module => 'Tie::StoredOrderHash',
            bench_code => sub {
                my ($op, $numkeys, $numrep) = @_;

                tie my %hash, "Tie::StoredOrderHash";
                for (1..$numkeys) { $hash{"key$_"} = $_ }

                if ($op eq 'delete') {
                    for (1..$numkeys) { delete $hash{"key$_"} }
                } elsif ($op eq 'keys') {
                    for (1..$numrep) { my @keys = keys %hash }
                } elsif ($op eq 'iterate') {
                    for (1..$numrep) { while (my ($k,$v) = each %hash) {} }
                }
            },
        },

        {
            module => 'Array::OrdHash',
            description => <<'MARKDOWN',

Provide something closest to PHP's associative array, where you can refer
elements by key or by numeric index, and insertion order is remembered.

MARKDOWN
            bench_code => sub {
                my ($op, $numkeys, $numrep) = @_;

                my $hash = Array::OrdHash->new;
                for (1..$numkeys) { $hash->{"key$_"} = $_ }

                if ($op eq 'delete') {
                    for (1..$numkeys) { delete $hash->{"key$_"} }
                } elsif ($op eq 'keys') {
                    for (1..$numrep) { my @keys = keys %$hash }
                } elsif ($op eq 'iterate') {
                    for (1..$numrep) { while (my ($k,$v) = each %$hash) {} }
                }
            },
        },

        {
            module => 'List::Unique::DeterministicOrder',
            description => <<'MARKDOWN',

Provide a list, not hash.

MARKDOWN
            bench_tags => ["no_iterate"].
            bench_code => sub {
                my ($op, $numkeys, $numrep) = @_;

                my $hash = List::Unique::DeterministicOrder->new(data=>[]);
                for (1..$numkeys) { $hash->push("key$_") }

                if ($op eq 'delete') {
                    for (1..$numkeys) { $hash->delete("key$_") }
                } elsif ($op eq 'keys') {
                    for (1..$numrep) { my @keys = $hash->keys }
                } elsif ($op eq 'iterate') {
                    for (1..$numrep) { while (my ($k,$v) = each %$hash) {} }
                }
            },
        },

        {
            module => 'Tree::RB::XS',
            description => <<'MARKDOWN',

Multi-purpose tree data structure which can record insertion order and act as an
ordered hash. Use `track_recent => 1, keys_in_recent_order => 1` options. Can
be used as a tied hash, or as an object (faster).

MARKDOWN
            bench_code => sub {
                my ($op, $numkeys, $numrep) = @_;

                my $tree= Tree::RB::XS->new(compare_fn => 'str', track_recent => 1, keys_in_recent_order => 1);
                for (1..$numkeys) { $tree->insert("key$_") }

                if ($op eq 'delete') {
                    for (1..$numkeys) { $tree->delete("key$_") }
                } elsif ($op eq 'keys') {
                    for (1..$numrep) { my @keys= $tree->keys }
                } elsif ($op eq 'iterate') {
                    for (1..$numrep) { my $iter = $tree->iter; while (my $v = $iter->next) {} }
                }
            },
        },
    ],

    bench_datasets => [
        {name=>'insert 1000 pairs', argv => ['insert', 1000]},
        {name=>'insert 1000 pairs + delete', argv => ['delete', 1000]},
        {name=>'insert 1000 pairs + return keys 100 times', argv => ['keys', 1000, 100]},
        {name=>'insert 1000 pairs + iterate 10 times', argv => ['iterate', 1000, 10], exclude_participant_tags => ['no_iterate']},
    ],
};

1;
# ABSTRACT:

=head1 DESCRIPTION


=head1 prepend:SEE ALSO

L<Acme::CPANModules::HashUtilities>
