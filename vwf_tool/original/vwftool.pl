
use strict;

if($#ARGV < 2){
	print "Usage: definition.txt list.txt output.txt\n";
	exit;
}
our @bin_data;
our %num_used;
our $cur_num=0;
our %definition;
our ($org_content,$content);

&define($ARGV[0]);
&convert($ARGV[1]);
&create($ARGV[2]);
print "\nDone!\n";
exit;

sub define
{
	my $def_path = $_[0];
	open(DEF,"<",$def_path) or die("Couldn't open ".$def_path." for reading\n");
	print "Loading user definition...\n";
	my $content;
	while(<DEF>){ $content .= $_; }
	close(DEF);
	$content =~ s/\s+//g;

	my @result;
	my $index=0;
	while($index < 0x51 && $content){
		if( $content =~ s/^(\[[^\[\]]+?\])// ){
			my $def = $1;
			die "Your tag: ".$def." is duplicated with the reserved tag.\n" if(&get_tag(\$def, \@result) != 0);
			$definition{$def}=$index++;
		}
		elsif( $content =~ s/^([^\[\]])// ){ $definition{$1}=$index++; }
		else{ die('Invalid tag found near "'.substr($content,0,5)."\".\nIt may be the tag is unclosed or it contains nothing.\n"); }
	}
	print "Finished defining\n\n";
}

sub convert
{
	my $list_path = $_[0];
	open(LIST,"<",$list_path) or die("Couldn't open ".$list_path." for reading\n");
	while(<LIST>){
		s/\/\/.*//;
		s/^\s+|\s+$//g;
		next unless($_);
		if(/^([0-9A-Fa-f]+)\s+(.+)$/){ &convert_txt($1,$2); }
		else{ die "Line ".$..": Invalid information, ".$_."\n"; }
	}
	close(LIST);
}

sub convert_txt
{
	my $number = hex($_[0]);
	my $msg_path = $_[1];
	die "The specified number is too high: ".$number."\n" if($number >= 0x100);
	open(MSG,"<","msg\\".$msg_path) or die("Couldn't open ".$msg_path." for reading\n");
	print "Loading ".$msg_path."...\n";
	local $content;
	while(<MSG>){ s/\/\/.*//; $content .= $_; }
	$content =~ s/^\s+|\s+$//g;
	$content =~ s/[ \r\t\f]+/ /g;
	local $org_content = $content;

	my $data = \@{$bin_data[$cur_num]};
	my %labels;
	my $str;
	my @result;
	my $command;
	for(my $pass=0; $pass<2; ++$pass){
		@$data = ();
		my @space = (-1);
		my $topic=0;
		$content = $org_content;
		while($content){
			if( $content =~ s/^(\[[^\[\]]+?\])// ){ $str = $1; }
			elsif( $content =~ s/^\s+// ){ $space[0]=1 if($space[0]>=0); next; }
			elsif( $content =~ s/^([^\[\]])//){ $str = $1; }
			else{ &error("Invalid tag found. It may be the tag is unclosed or it contains nothing."); }
			if(exists $definition{$str}){

				if($space[0]>0){ push(@$data,0x81); }
				push(@$data,$definition{$str});
				$space[0]=0;
				
			}elsif( $command = get_tag(\$str,\@result)){
				push(@$data,$command) if($command & 0x80);

				    if($command == 0x01){ #label
					$labels{$result[1]} = $#{$data} + 1;
				}elsif($command == 0x80){ #end
					$space[0]=-1;
					   if($result[1] =~ /^exit$/) { push(@$data,0x20); }
					elsif($result[1] =~ /^goal$/) { push(@$data,0x21); }
					elsif($result[1] =~ /^sgoal$/){ push(@$data,0x22); }
					else{
						if( ($_ = hex($result[1])) < 0x20){ push(@$data,$_); }
						else{ &error("The specified number in [end=*] is too high.");}
					}
				}elsif($command == 0x82){ #line break
					$space[0]=-1;
				}elsif($command == 0x84){ #wait timer
					if($result[1]<256){ push(@$data,$result[1]); }
					else{ &error("The specified number in [wait=*] is too high."); }
				}elsif($command == 0x88){ #pad left
					if($result[1]<256){ push(@$data,$result[1]); }
					else{ &error("The specified number in [pad left=*] is too high."); }
				}elsif($command == 0x89){ #pad right
					if($result[1]<256){ push(@$data,$result[1]); }
					else{ &error("The specified number in [pad right=*] is too high."); }
				}elsif($command == 0x8A){ #pad both
					if($result[1]<256 && $result[2]<256){ push(@$data,$result[1],$result[2]); }
					else{ &error("The specified number in [pad=*,*] is too high."); }
				}elsif($command == 0x8B){ #music
					if(hex($result[1])<256){ push(@$data,hex($result[1])); }
					else{ &error("The specified number in [music=*] is too high."); }
				}elsif($command == 0x8C){ #erase
					$space[0]=-1;
				}elsif($command == 0x8D){ #topic
					if(++$topic & 1){ unshift(@space,-1); }
					else{ shift(@space); }
				}elsif($command == 0x8E){ #sprite
					my $loop = hex($result[1]);
					if($loop == 0 || $loop >= 128){ &error("The specified number in [sprite=*] is not in the range 1-7F."); }
					push(@$data,$loop);
					if($content =~ s/^\s*((?:.|\s)*?)\s*\[\s*\/sprite\s*\]//){
						$_ = $1; s/\s+//g;
						while($_){
							if( s/^\(([0-9A-Fa-f]+),([0-9A-Fa-f]+),([0-9A-Fa-f]+),([0-9A-Fa-f]+),(big|small)\)// ){
								push(@$data,hex($1),hex($2),hex($3),(hex($4)&0xCF)|($5 =~ "big" ? 0x20 : 0));
								--$loop;
							}else{ &error("Invalid attributes in [sprite=*,*][/sprite]"); }
						}
						if($loop){ &error("The number of attributes in [sprite=*,*][/sprite] not matched to the loop number"); }
					}else{ &error("Unclosed [sprite] tag found."); }
				}elsif($command == 0x90){ #branch
					$space[0]=-1;
					my @branches = split(/,/, $result[1]);
					my $num = @branches;
					&error("The number of labels in [branch=*] is either too high or too small.") if($num<2 || 5<$num);
					if($pass == 0){
						#for the first pass
						push(@$data,0);
						for(my $i=0; $i<$num; ++$i){ push(@$data,0,0); }
					}else{
						push(@$data,$num|($result[0]=~/^\[\s*branch2/ ? 0x80 : 0));
						foreach(@branches){
							s/^\s+|\s+$//g;
							&error("The empty label is specified in [branch=*].") unless($_);
							if(exists($labels{$_})){
								push(@$data,$labels{$_}&0xFF,$labels{$_}>>8);
							}else{ &error("The label in [branch=*] not defined yet."); }
						}
					}
				}elsif($command == 0x91){ #jump
					$space[0]=-1;
					if($pass == 0){ push(@$data,0,0); }
					else{
						if(exists($labels{$result[1]})){
							push(@$data,$labels{$result[1]}&0xFF,$labels{$result[1]}>>8);
						}else{ die("The label in [jump=*] not defined yet."); }
					}
				}elsif($command == 0x92){ #skip
					if($pass == 0){ push(@$data,0,0); }
					else{
						if(exists($labels{$result[1]})){
							push(@$data,$labels{$result[1]}&0xFF,$labels{$result[1]}>>8);
						}else{ die("The label in [skip=*] not defined yet."); }
					}
				}
			}else{ &error("Undefined command: ".$str); }
		}
	}
	$num_used{$number} = $cur_num++;
	printf "Conversion finished. (size: 0x%X)\n",$#{$data}+1;
	close(MSG);
}

sub get_tag
{
	$_ = $_[0];
	my $result = $_[1];
	if( $$_ =~ /^\[\s*end\s*=\s*([0-9A-Fa-f]+|exit|s?goal)\s*\]/ )		{ @$result=($&,$1);	return 0x80; }
	if( $$_ =~ /^\[ \]/ )							{ @$result=($&);	return 0x81; }
	if( $$_ =~ /^\[\s*br\s*\]/ )						{ @$result=($&);	return 0x82; }
	if( $$_ =~ /^\[\s*wait\s*\]/ )						{ @$result=($&);	return 0x83; }
	if( $$_ =~ /^\[\s*wait\s*=\s*(\d+)\s*\]/ )				{ @$result=($&,$1);	return 0x84; }
	if( $$_ =~ /^\[\s*(?:font\s+colou?r\s*=\s*1|\/font\s+colou?r)\s*\]/ )	{ @$result=($&);	return 0x85; }
	if( $$_ =~ /^\[\s*font\s+colou?r\s*=\s*2\s*\]/ )			{ @$result=($&);	return 0x86; }
	if( $$_ =~ /^\[\s*font\s+colou?r\s*=\s*3\s*\]/ )			{ @$result=($&);	return 0x87; }
	if( $$_ =~ /^\[\s*pad\s+left\s*=\s*(\d+)\s*\]/ )			{ @$result=($&,$1);	return 0x88; }
	if( $$_ =~ /^\[\s*pad\s+right\s*=\s*(\d+)\s*\]/ )			{ @$result=($&,$1);	return 0x89; }
	if( $$_ =~ /^\[\s*pad\s*=\s*(\d+)\s*,\s*(\d+)\s*\]/ )			{ @$result=($&,$1,$2);	return 0x8A; }
	if( $$_ =~ /^\[\s*music\s*=\s*([0-9a-fA-F]+)\s*\]/ )			{ @$result=($&,$1);	return 0x8B; }
	if( $$_ =~ /^\[\s*erase\s*\]/ )						{ @$result=($&);	return 0x8C; }
	if( $$_ =~ /^\[\s*\/?topic\s*\]/ )					{ @$result=($&);	return 0x8D; }
	if( $$_ =~ /^\[\s*sprite\s*=\s*([0-9A-Fa-f]+)\s*\]/ )			{ @$result=($&,$1,$2);	return 0x8E; }
	if( $$_ =~ /^\[\s*sprite\s*=\s*erase\s*\]/ )				{ @$result=($&);	return 0x8F; }
	if( $$_ =~ /^\[\s*branch2?\s*=\s*(.+)\s*\]/ )				{ @$result=($&,$1);	return 0x90; }
	if( $$_ =~ /^\[\s*jump\s*=\s*(.+)\s*\]/ )				{ @$result=($&,$1);	return 0x91; }
	if( $$_ =~ /^\[\s*skip\s*=\s*(.+)\s*\]/ )				{ @$result=($&,$1);	return 0x92; }
	if( $$_ =~ /^\[\s*\/\s*skip\s*\]/ )					{ @$result=($&);	return 0x93; }

	if( $$_ =~ /^\[\s*label\s*=\s*(.+)\s*\]/ )				{ @$result=($&,$1);	return 0x01; }

	@$result = ();
	return 0x00;
}

sub error
{
	my $error = $_[0];

	my $current_pos = rindex($org_content,$content);
	my $line=1; my $pos;
	while( ($pos = index($org_content,"\n",$pos)) >= 0){
		last if( $pos >= $current_pos );
		++$pos;
		++$line;
	}

	die("Line ".$line.(length($content) ? ', near "'.eval{$_ = substr($content,0,10); s/\n//g; $_;}."\"\n" : ", near the end of file\n").$error."\n");
}

sub create
{
	my $out_path = $_[0];
	open(OUT,">",$out_path) or die("Couldn't open ".$out_path." for writing.\n");
	my $ptr="DataPtr:";
	my $bin;
	for(my $i=0; $i<0x100 && keys(%num_used); ++$i){
		$ptr .= (!($i&15) ? "\n\t\t\tdw " : ",");
		if(exists $num_used{$i}){
			$ptr .= sprintf(".%02X",$i);
			$bin .= sprintf("\n.%02X",$i);
			my $j=0;
			foreach( @{$bin_data[$num_used{$i}]}){
				$bin .= (!($j++&0x1F) ? "\n\t\t\tdb " : ",") . sprintf('$%02X',$_&0xFF);
			}
			delete $num_used{$i};
		}else{
			$ptr .= '0';
		}
	}
	print OUT <<'MULTI';
print "INIT ",pc
PHX
PHK
PLA
STA $7ED002
REP #$30
LDA $E4,x
AND #$00F0
LSR #3
STA $00
LDA $D8,x
AND #$00F0
ASL A
ORA $00
TAX
LDA DataPtr,x
STA $7ED000
SEP #$30
PLX
print "MAIN ",pc
RTL
MULTI
	print OUT $ptr.$bin;
	close(OUT);
}


