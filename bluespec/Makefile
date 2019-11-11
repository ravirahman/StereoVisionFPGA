bscflags = -keep-fires -aggressive-conditions -Xc++ -D_GLIBCXX_USE_CXX11_ABI=0
bsvdir = ./
build_dir = bscdir


compile: $(file) $(test_file)
	mkdir -p bscdir
	bsc -u -sim -simdir $(build_dir) -bdir $(build_dir) -info-dir $(build_dir) $(bscflags) -p +:$(bsvdir) -g mkTest $(test_file)

link: compile
	bsc -e mkTest -sim -o ./out -simdir $(build_dir) -bdir $(build_dir) -info-dir $(build_dir) $(bscflags)

simulation: link

verilog: $(file)
	mkdir -p bscdir
	bsc -u -verilog -elab -vdir $(build_dir) -bdir $(build_dir) -info-dir $(build_dir) $(bscflags) -p +:$(bsvdir) -g $(module) $(file)

synth: $(file) 
	synth $(file) $(module) -p ./ -l multisize

clean:
	rm bscdir out out.so -rf
