#!/usr/bin/perl

%num_op;

while($line = <>){

    #language interpreter 
    if($line =~ /^#!/){
        $line =~ s/#!\/usr\/bin\/python3/#!\/usr\/bin\/perl -w/g;
    }
   
    #subset 0-3 print statements
    if($line !~ /\[.*\]|\" %/){
        #printing strings
        if($line =~ /print\(\".*\"\)/){
            $line =~ s/\(/ /g;
            $line =~ s/\"\)/\\n";/g;
        #printing variables
        } elsif($line =~ /print\(.+\)/) {
            $line =~ s/\(/ /g;
            $line =~ s/\)/."\\n";/g;
        #situation where it just prints a new line 
	}elsif($line =~ /print\(\)/){
            $line =~ s/\(\)/"\\n";/g;
        }
    }
    #subset 4 print formating for list
    if($line =~ /\[.*\]|\" %/){
        if($line =~ /print\(.*\[.*\].*,.*\)/){
             $line =~ s/,.*\)/."\\n";/g;
             $line =~ s/\(/ /g;
        }
    }

    #variables using capture and adding it to an array
    if($line !~ /\[\]/){
        if($line =~ /\s*([A-z_]\w*) [+=-=] [-\w*]/){
            $var = "$1";
            $line =~ s/\n/;\n/g;
 	    #making sure that there is no repeats of variables
            if(!grep /\b$var\b/, @v){
                push @v, $var;
            }
        }
    }


    #for in range case where there is only one argument
    #grab the varible and put it into the variable array 
    if($line =~ /^\s*for ([A-z_]\w*) in range\((\w+)\):/){
        $var = "$1";
        $num = "$2";
        $newnum = "$num-1";
        $line =~ s/for/foreach/g;
        $line =~ s/in range\(/(0../g;
        $line =~ s/:/\{\n/g;
        $line =~ s/$num/$newnum/g;
        if(!grep /\b$var\b/, @v){
            push @v, $var;
        }
    }
    #pop element for subset 4
    if($line =~ /([A-z_]\w*)\.pop\(\)/){
        $ar = "$1";
        if(!grep /\b$ar\b/, @arr){
            push @arr, $ar;
        }
        $line =~ s/\Q$line/pop $ar;\n/g;
    }

    #for in range for two arguements
    #made sure of if second arguement might actually be a varible
    if($line =~ /^\s*for ([A-z_]\w*) in range\(\w+\, [\w\d]+[ +\- \w\d\)]+:/){
        $var = "$1";
        $line =~ s/for/foreach/g;
        $line =~ s/in range//;
        $line =~ s/, /\.\./g;
        $line =~ s/:/{\n/g;
        #dodgy way of decrementing
        $line =~ s/\)/-1)/g;
        if(!grep /\b$var\b/, @v){
            push @v, $var;
        }
     }
    #forgot what i did here probably to do with varibles?
    if($line =~ /^\s*([A-z_]\w*) = \W+/){
        $a = "$1";
        if(!grep /\b$a\b/, @arr){
            push @arr, $a;
        }
        #removed the line
        $line =~ s/\Q$line//g;
    }

    #reading from standard with help of foreach
    if($line =~ /for ([A-z_]\w*) in sys.stdin:/){
        $var = "$1";
        if(!grep /\b$var\b/, @v){
            push @v, $var;
        }
        $line =~ s/for/foreach/g;
        $line =~ s/in sys.stdin:/(<STDIN>) {/;
    }
    #push version of perl
    #needed to change a few capture and sed
    if($line =~ /(^\s*)([A-z_]\w*).append\(([A-z_]\w*)\)/){
        $ind = "$1";
        $p1 = "$2";
        $p2 = "$3";
        $line =~ s/\Q$line/$ind push $p1, $p2;/g;
    }
    #adding an @ in front of array varibles
    for $aa (@arr){
        $line =~ s/\b$aa\b/\@$aa/g;
    }

    #adding a $ in front of varibles names
    for $c (@v){
        $line =~ s/\b$c\b/\$$c/g;
    }
    #used to avoid \n to be changed to \$n
    if($line =~ /\\\$n/){
        $line =~ s/\\\$n/\\n/g;
    }    
   #used to avoid $ being added in quotation
   if($line =~ /\"\$.*\";/){
        $line =~ s/\"\$/"/g;
    }

    #single line while loops
    if($line =~ /\bif .*: .+/){
        $line =~ s/if /if (/g;
        $line =~ s/:/){\n   /g;
        $line =~ s/;/;\n   /g;
        $line =~ s/\n$/;\n}\n/g; 
    }

    #delete all import
    if($line =~ /^import\s*[a-zA-Z]+\n/){
        $line =~ s/import .*\n//g;
    }

    #sys.stdout.write is the other version of print
    if($line =~ /sys.stdout.write\(\".*\"\)/){
        $line =~ s/sys.stdout.write\(/print /g;
        $line =~ s/\)/;/g;
    }
   
    #another way of writing stdin
    if($line =~ /[a-z]*\(sys.stdin.readline\(\)\)/){
        $line =~ s/[a-z]*\(sys.stdin.readline\(\)\)/<STDIN>/g;
    }

    #multiline while loops
    if($line !~ /;/){
        if($line =~ /while .*:$/){
            $line =~ s/while /while (/g;
            $line =~ s/:/){\n    /g;
        }
    }
   #single line while loop
    if ($line =~ /while .*: .+/){
        $line =~ s/while /while (/g;
	$line =~ s/\n$/;\n}\n/g;
        $line =~ s/:/) {\n    /g;
        $line =~ s/;/;\n    /g;
    }
    #indentation for lines fails in one scenario but fixed up later below
    #doesnt affect elif,#,else,if, while
    #checks previous and current indentation and adds a } is indentation is different
    #capture spaces at beginning of line
    if($line !~ /elif|#|else|if .*: .*\n|while .*: .*/){
        if($line =~ /(\s*).*\n/){
            $indent = "$1";
            $curr = $indent;
            if($curr lt $prev){
                #$line =~ s/$indent/$curr}\n$curr/g;
                $line = "$curr} \n$line";
            }
            if(eof and $curr =~ /^(\s+)/){
                $line = "$line}\n";
            }
            $prev = $curr;
        }
    }
    #mulitline if statements
    if($line =~ /\bif .*:/){
        $line =~ s/\bif\b /if (/g;
        $line =~ s/:/){/g;
    }
    #elif statements
    if($line =~ /elif .*:$/){
        $line =~ s/elif/}elsif (/g;
        $line =~ s/:/){/g;
    } 
    #else statements
    if($line =~ /else:/){
        $line =~ s/else:/} else {/g;
    }


    #division operator of \\ to ]
    if($line =~ m/ \/\/ /){
        $line =~ s/ \/\/ /\//g;
    }
    #changing break to last
    if($line =~ /break/){
        $line =~ s/break/last;/g;
    }
    #change continue to next
    if($line =~ /continue/){
        $line =~ s/continue/next;/g;
    }

    #checks to see if len() has an array if it does 
    #perform just the removal of len
    if($line =~ /len\(@.*\)/){
        if($line =~ /[A-z_]\w* = len\((.*)\).*/){
            $line =~ s/len\(//g;
            $line =~ s/\)//g;
        }
    }
    #other condition if len has a variable in it just
    #changes len to length
    if($line =~ /len\(\$.*\)/){
        if($line =~ /[A-z_]\w* = len\((.*)\).*/){
            $line =~ s/len\(/length(/g;
        }
    }
    #if there is an array in print just make the @ to $ for indexing
    if($line =~ /print @.*/){
        $line =~ s/@/\$/g;
    }

    #add all the lines to an array
    push @test, $line;
}

#subroutine for helping the lost indentation
sub firstL(){
    my ($line) = @_;
    for ($i = 0; $i < length($line); $i++) {
        if(substr($line, $i, 1) ne ' '){
            return $i;
        }
    }
}

#varible for prevoius indentation
$prev_in = 0;
#printing out the lines along with the missing indentation
foreach $line (@test){
    $curr_in = &firstL($line)/4;
    if($line =~ /\{/){
        $num_op{$curr_in}++;
    }
        if($line =~ /\}/){
            $num_op{$curr_in}--;
        }
    if($curr_in < $prev_in){

        foreach $in (($curr_in+1)..($prev_in-1)){
            if($num_op{$in} > 0){
  		#prints out missing indentation
                printf("    "x($prev_in-$in)."}\n");
                $num_op{$in}--;
            }
        }
    }
    $prev_in = $curr_in;
    #print out the lines
    print $line;
}


