# ABOUT
# - In this Makefile, 'building a file' means:
# 	- if the file has a '.html' extension: run the html preprocessor on the file and place the output in the output directory
# 	- else: copy the file to the output directory
# - Folder structure from source directories will be preserved in the output directory
# - Abbreviations:
#   - FLS: files
#   - DIR: directory
#   - SRC: source
#   - LANG: language
#   - PP: preprocessor
#   - DEP: dependency

# TODO: fix that you have invoke make twice to build both languages

#
# NORMAL SETTINGS
# change these to fir your project
#

# root dir for the project, all other paths relative to PROJECT_DIR (except for OUT_DIR)
PROJECT_DIR 	= .

# path where final website will be in, this one is not relative to PROJECT_DIR
OUT_DIR 		= ../quintern-test

# SOURCE FILES:
# all SRC_FLS and all files in the SRC_DIRS will be built
SRC_DIRS 		= de en script style
SRC_FLS 		= rss.xml

# SOURCE FILES:
# all RESOURCE_FLS and all files in the RESOURCE_DIRS will be copied to OUT_DIR
RESOURCE_DIRS 	= resources 
RESOURCE_FLS	= 


# MULTI-LANG SOURCE FILES:
# the files in COMMON_DIR will be built for all LANGS:
# foreach html-file in COMMON_DIR:
# 	foreach lang in LANGS:
# 		run HTML_PP_CMD with --var lang=lang on file and output to OUT_DIR without the COMMON_DIR prefix, so COMMON_DIR/subdir/file.html -> OUT_DIR/lang/subdir/file.html
# all non-html files will handled the same way, but without the preprocessor being run on them. They are simply copied
COMMON_DIR 		= common
LANGS 			= de en

# PREPROCESSOR
# path to of the files that should be included
INCLUDE_DIR 	= include


# ADVANCED
# the command to run the html preprocessor
HTML_PP_CMD 	= python3 html_preprocessor.py --exit-on light

DEP_DIR 		= .dependencies



#
# NOT SETTINGS ANYMORE
# DO NOT CHANGE ANYTHING HERE UNLESS YOU KNOW WHAT YOU ARE DOING!
#
# all variables starting with _ are relative to PROJECT_DIR

# make everything relative to PROJECT_DIR
_SRC_DIRS 		= $(addprefix $(PROJECT_DIR)/, $(SRC_DIRS))
_SRC_FLS 		= $(addprefix $(PROJECT_DIR)/, $(SRC_FLS))
_RES_DIRS 		= $(addprefix $(PROJECT_DIR)/, $(RESOURCE_DIRS))
_RES_FLS 		= $(addprefix $(PROJECT_DIR)/, $(RESOURCE_FLS))
_COMMON_DIR 	= $(addprefix $(PROJECT_DIR)/, $(COMMON_DIR))
_INCLUDE_DIR 	= $(addprefix $(PROJECT_DIR)/, $(INCLUDE_DIR))
_DEP_DIR 		= $(addprefix $(PROJECT_DIR)/, $(DEP_DIR))

# NORMAL SRC
# all SRC_DIRS + all subdirs of each srcdir
_SRC_SUB_DIRS 	= $(foreach srcdir, $(_SRC_DIRS), $(shell find $(srcdir)/ -type d))
_SRC_FLS		+= $(foreach srcdir, $(_SRC_DIRS), $(shell find $(srcdir)/ -type f))
# OUT_DIRS 	 	= $(OUT_DIR) $(addprefix $(OUT_DIR)/, $(_SRC_SUB_DIRS))
OUT_DIRS 		= $(OUT_DIR)/ $(patsubst $(PROJECT_DIR)/%, $(OUT_DIR)/%, $(_SRC_SUB_DIRS))
# path of the source files after being processed
# OUT_FLS 		= $($(notdir _SRC_FLS):%=$(OUT_DIR)/%)
OUT_FLS 		= $(patsubst $(PROJECT_DIR)/%, $(OUT_DIR)/%, $(_SRC_FLS))

# RESOURCES
_RES_SUB_DIRS 	= $(foreach srcdir, $(_RES_DIRS), $(shell find $(srcdir)/ -type d))
_RES_FLS		+= $(foreach srcdir, $(_RES_DIRS), $(shell find $(srcdir)/ -type f))
RES_OUT_DIRS 	= $(OUT_DIR)/ $(patsubst $(PROJECT_DIR)/%, $(OUT_DIR)/%, $(_RES_SUB_DIRS))
RES_OUT_FLS 	= $(patsubst $(PROJECT_DIR)/%, $(OUT_DIR)/%, $(_RES_FLS))

# MULTILANG
_ML_SRC_FLS 	= $(shell find $(_COMMON_DIR)/ -type f)	
_ML_SRC_SUB_DIRS= $(shell find $(_COMMON_DIR)/ -type d)
# will contain one subdir for each lang, each of which contains every file from ML_SRC_FLS
ML_OUT_DIR 		= $(OUT_DIR)
ML_OUT_LANG_DIRS= $(foreach lang, $(LANGS), $(addprefix $(ML_OUT_DIR)/, $(lang)))
ML_OUT_DIRS		= $(foreach lang, $(LANGS), $(patsubst $(_COMMON_DIR)/%, $(ML_OUT_DIR)/$(lang)/%, $(_ML_SRC_SUB_DIRS)))
ML_OUT_FLS 		= $(foreach lang, $(LANGS), $(patsubst $(_COMMON_DIR)/%, $(ML_OUT_DIR)/$(lang)/%, $(_ML_SRC_FLS)))

# needed for creating them
_DEP_DIRS 		= $(sort $(patsubst $(OUT_DIR)/%, $(_DEP_DIR)/%, $(OUT_DIRS) $(ML_OUT_DIRS)))
# needed for reading
_DEP_FLS 		= $(shell find $(_DEP_DIR) -type f -name '*.d')

# PRINTING
FMT_VAR_SRC		="Variable '\e[1;34m%s\e[0m': \e[0;33m%s\e[0m\n"
FMT_VAR_OUT		="Variable '\e[1;34m%s\e[0m': \e[0;35m%s\e[0m\n"
FMT_DIR			="\e[1;34mMaking directory\e[0m: \e[0;35m%s\e[0m\n"
FMT_OUT_HTML	="\e[1;34mBuilding html\e[0m \e[1;33m%s\e[0m at \e[1;35m%s\e[0m\n"
FMT_OUT_OTHER	="\e[1;34mBuilding\e[0m: \e[1;33m%s\e[0m at \e[1;35m%s\e[0m\n"

FMT_OUT_ML_HTML="\e[1;34mBuilding html\e[0m in lang \e[1;34m%s\e[0m: \e[1;33m%s\e[0m at \e[1;35m%s\e[0m\n"
FMT_OUT_ML_OTHER="\e[1;34mBuilding\e[0m in lang \e[1;34m%s\e[0m: \e[1;33m%s\e[0m at \e[1;35m%s\e[0m\n"
.SUFFIXES:
.SUFFIXES: .html .md

.PHONY: default normal multilang resources print start stop clean cleaner

.DEFAULT_GOAL 	= all

# include all the dependency makefiles
include $(_DEP_FLS)

all: normal multilang resources
normal:	$(OUT_FLS)
multilang: $(ML_OUT_FLS)
resources: $(RES_OUT_FLS)

print:
	@printf $(FMT_VAR_SRC) "PROJECT_DIR" 	"$(PROJECT_DIR)"
	@printf $(FMT_VAR_OUT) "OUT_DIRS" 		"$(OUT_DIRS)"
	@printf $(FMT_VAR_SRC) "_INCLUDE_DIR" 	"$(_INCLUDE_DIR)"
	@printf $(FMT_VAR_SRC) "_SRC_FLS" 		"$(_SRC_FLS)"
	@printf $(FMT_VAR_OUT) "OUT_FLS" 		"$(OUT_FLS)"
	@printf $(FMT_VAR_SRC) "_RES_FLS" 		"$(_RES_FLS)"
	@printf $(FMT_VAR_OUT) "RES_OUT_FLS" 	"$(RES_OUT_FLS)"
	@printf $(FMT_VAR_SRC) "_ML_SRC_FLS" 	"$(_ML_SRC_FLS)"
	@printf $(FMT_VAR_OUT) "ML_OUT_FLS" 	"$(ML_OUT_FLS)"
	@printf $(FMT_VAR_SRC) "_DEP_FLS" 		"$(_DEP_FLS)"
	@# @printf $(FMT_VAR_SRC) "y" 		"$(y)"

# MULTILANG RULES
$(sort $(ML_OUT_DIRS) $(_DEP_DIRS) $(RES_OUT_DIRS) $(OUT_DIRS)):
	@printf $(FMT_DIR) "$@"
	@mkdir -p $@

# build/ml_tmp/lang/subdir/xyz.html
$(foreach out_dir, $(ML_OUT_LANG_DIRS), $(out_dir)/%.html): $(_COMMON_DIR)/%.html | $(ML_OUT_DIRS) $(_DEP_DIRS)
	@#echo "$$@=$@, $$<=$< $$^=$^"
	@# \$@=build/ml_tmp/lang/subdir/xyz.html, \$<=common/subdir/xyz.html
	@lang=`echo $(patsubst $(ML_OUT_DIR)/%, %, $@) | awk -F "/" '{print $$1}'`; \
	printf $(FMT_OUT_ML_HTML) "$$lang" "$<" "$@"; \
	$(HTML_PP_CMD) --target "$<" --output "$@" --var include_dir=$(_INCLUDE_DIR) --var lang=$$lang --output-deps "$(patsubst $(OUT_DIR)/%, $(_DEP_DIR)/%.d, $@)";

# rule for all not html files
$(foreach out_dir, $(ML_OUT_LANG_DIRS), $(out_dir)/%): $(_COMMON_DIR)/% | $(ML_OUT_DIRS)
	@lang=`echo $(patsubst $(ML_OUT_DIR)/%, %, $@) | awk -F "/" '{print $$1}'`; \
	printf $(FMT_OUT_ML_OTHER) "$$lang" "$<" "$@" ; \
	cp $< $@

#
# (NORMAL/RE-)SOURCE RULES
# 


$(OUT_DIR)/%.html: %.html | $(OUT_DIRS) $(_DEP_DIRS)
	@printf $(FMT_OUT_HTML) "$<" "$@";
	$(HTML_PP_CMD) --target "$<" --output "$@" --var include_dir=$(_INCLUDE_DIR) --output-deps "$(_DEP_DIR)/$<.d";
	@# remove comments and empty lines. two separate lines bc the substitution might create new empty lines
	@#awk -i inplace '{FS="" sub(/<!--.*-->/,"")}1' $@
	@#awk -i inplace '{if (NF != 0) print}' $@

$(OUT_DIR)/%: % | $(OUT_DIRS) $(RES_OUT_DIRS)
	@printf $(FMT_OUT_OTHER) "$<" "$@"
	@cp -r $< $@


# .DEFAULT:
# 	@echo "MISSING RULE: $@"

start:
	/usr/sbin/nginx -c nginx.conf -p $(shell pwd)&
	firefox http://localhost:8080/
stop:
	killall nginx

clean:
	-rm $(OUT_FLS) $(ML_OUT_FLS)
	-rm -r $(_DEP_DIR)

cleaner:
	-rm -r $(OUT_DIR)
