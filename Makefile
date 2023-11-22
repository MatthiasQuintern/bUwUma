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

# root dir for the project, all other paths relative to PROJECT_DIR (except for OUT_DIR and DEP_DIR)
PROJECT_DIR 	= src

# path where final website will be in, this one is not relative to PROJECT_DIR
OUT_DIR 		= build

# SOURCE FILES:
# all SRC_FLS and all files (recursively) in the SRC_DIRS will be built
# all files in PROJECT_DIR (not recursively) are source files
SRC_DIRS 		= de en script style
SRC_FLS 		= 

# RESOURCE FILES:
# all RESOURCE_FLS and all files in the RESOURCE_DIRS will be copied to OUT_DIR
RESOURCE_DIRS 	= resources 
RESOURCE_FLS	= 
# THUMBNAILS:
# if set, thumbnails for all resource files will be generated and placed in THUMB_OUT_DIR (relative to OUT_DIR)
THUMB_OUT_DIR 	= thumbs

# MULTI-LANG SOURCE FILES:
# the files in COMMON_DIR will be built for all LANGS:
# foreach html-file in COMMON_DIR:
# 	foreach lang in LANGS:
# 		run HTML_PP_CMD with --var lang=lang on file and output to OUT_DIR without the COMMON_DIR prefix, so COMMON_DIR/subdir/file.html -> OUT_DIR/lang/subdir/file.html
# all non-html files will handled the same way, but without the preprocessor being run on them. They are simply copied
# leave COMMON_DIR empty to disable multi-lang feature
COMMON_DIR 		= 
LANGS 			= de en

# PREPROCESSOR
# path to of the files that should be included
INCLUDE_DIR 	= include


# ADVANCED
# the command to run the html preprocessor
HTML_PP_CMD 	= python3 html-preprocessor --exit-on light

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

# NORMAL SRC
# all SRC_DIRS + all subdirs of each srcdir
_SRC_SUB_DIRS 	= $(foreach srcdir, $(_SRC_DIRS), $(shell find $(srcdir)/ -type d 2>/dev/null))
# add files in project dir
_SRC_FLS		+= $(shell find $(PROJECT_DIR)/ -maxdepth 1 -type f)
# add files src dirs, recursively
_SRC_FLS		+= $(foreach srcdir, $(_SRC_DIRS), $(shell find $(srcdir)/ -type f 2>/dev/null))
# OUT_DIRS 	 	= $(OUT_DIR) $(addprefix $(OUT_DIR)/, $(_SRC_SUB_DIRS))
OUT_DIRS 		= $(OUT_DIR)/ $(patsubst $(PROJECT_DIR)/%, $(OUT_DIR)/%, $(_SRC_SUB_DIRS))
# path of the source files after being processed
# OUT_FLS 		= $($(notdir _SRC_FLS):%=$(OUT_DIR)/%)
OUT_FLS 		= $(patsubst $(PROJECT_DIR)/%, $(OUT_DIR)/%, $(_SRC_FLS))

# RESOURCES
_RES_SUB_DIRS 	= $(foreach srcdir, $(_RES_DIRS), $(shell find $(srcdir)/ -type d 2>/dev/null))
_RES_FLS		+= $(foreach srcdir, $(_RES_DIRS), $(shell find $(srcdir)/ -type f 2>/dev/null))
RES_OUT_DIRS 	= $(OUT_DIR)/ $(patsubst $(PROJECT_DIR)/%, $(OUT_DIR)/%, $(_RES_SUB_DIRS))
RES_OUT_FLS 	= $(patsubst $(PROJECT_DIR)/%, $(OUT_DIR)/%, $(_RES_FLS))

# MULTILANG
ifdef COMMON_DIR
_ML_SRC_FLS 	= $(shell find $(_COMMON_DIR)/ -type f)	
_ML_SRC_SUB_DIRS= $(shell find $(_COMMON_DIR)/ -type d)
# will contain one subdir for each lang, each of which contains every file from ML_SRC_FLS
ML_OUT_DIR 		= $(OUT_DIR)
ML_OUT_LANG_DIRS= $(foreach lang, $(LANGS), $(addprefix $(ML_OUT_DIR)/, $(lang)))
ML_OUT_DIRS		= $(foreach lang, $(LANGS), $(patsubst $(_COMMON_DIR)/%, $(ML_OUT_DIR)/$(lang)/%, $(_ML_SRC_SUB_DIRS)))
ML_OUT_FLS 		= $(foreach lang, $(LANGS), $(patsubst $(_COMMON_DIR)/%, $(ML_OUT_DIR)/$(lang)/%, $(_ML_SRC_FLS)))
endif

ifdef THUMB_OUT_DIR
_THUMB_FOR_TYPES = png gif jpg jpeg webp pdf 
_THUMB_TYPE 	= jpg
# files for which to generate thumbnails
_THUMB_FLS 		= $(filter $(foreach type, $(_THUMB_FOR_TYPES), %.$(type)), $(_RES_FLS))
THUMB_OUT_FLS 	= $(addsuffix .jpg, $(basename $(patsubst $(PROJECT_DIR)/%, $(OUT_DIR)/$(THUMB_OUT_DIR)/%, $(_THUMB_FLS))))
THUMB_OUT_DIRS	= $(sort $(dir $(THUMB_OUT_FLS)))  # sort for removing duplicates
endif

# needed for creating them
_DEP_DIRS 		= $(sort $(patsubst $(OUT_DIR)/%, $(DEP_DIR)/%, $(OUT_DIRS) $(ML_OUT_DIRS)))
# needed for reading
_DEP_FLS 		= $(shell find $(DEP_DIR) -type f -name '*.d' 2>/dev/null)

# PRINTING
FMT_VAR_SRC		="Variable '\e[1;34m%s\e[0m': \e[0;33m%s\e[0m\n"
FMT_VAR_OUT		="Variable '\e[1;34m%s\e[0m': \e[0;35m%s\e[0m\n"
FMT_DIR			="\e[1;34mMaking directory\e[0m: \e[0;35m%s\e[0m\n"
FMT_OUT_HTML	="\e[1;34mBuilding html\e[0m: \e[1;33m%s\e[0m at \e[1;35m%s\e[0m\n"
FMT_OUT_THUMB	="\e[1;34mBuilding thumbnail\e[0m: \e[1;33m%s\e[0m at \e[1;35m%s\e[0m\n"
FMT_OUT_OTHER	="\e[1;34mBuilding\e[0m: \e[1;33m%s\e[0m at \e[1;35m%s\e[0m\n"

FMT_OUT_ML_HTML="\e[1;34mBuilding html\e[0m in lang \e[1;34m%s\e[0m: \e[1;33m%s\e[0m at \e[1;35m%s\e[0m\n"
FMT_OUT_ML_OTHER="\e[1;34mBuilding\e[0m in lang \e[1;34m%s\e[0m: \e[1;33m%s\e[0m at \e[1;35m%s\e[0m\n"
.SUFFIXES:
.SUFFIXES: .html .md

.PHONY: default normal multilang resources print start stop clean cleaner

.DEFAULT_GOAL 	= all

# include all the dependency makefiles
include $(_DEP_FLS)

all: normal multilang resources thumbnails
normal:	$(OUT_FLS)
multilang: $(ML_OUT_FLS)
resources: $(RES_OUT_FLS)
thumbnails: $(THUMB_OUT_FLS)

print:
	@printf $(FMT_VAR_SRC) "PROJECT_DIR" 	"$(PROJECT_DIR)"
	@printf $(FMT_VAR_OUT) "OUT_DIRS" 		"$(OUT_DIRS)"
	@printf $(FMT_VAR_SRC) "_INCLUDE_DIR" 	"$(_INCLUDE_DIR)"
	@printf $(FMT_VAR_SRC) "_SRC_FLS" 		"$(_SRC_FLS)"
	@printf $(FMT_VAR_OUT) "OUT_FLS" 		"$(OUT_FLS)"
	@printf $(FMT_VAR_SRC) "_RES_FLS" 		"$(_RES_FLS)"
	@printf $(FMT_VAR_OUT) "RES_OUT_FLS" 	"$(RES_OUT_FLS)"
ifdef COMMON_DIR
	@printf $(FMT_VAR_SRC) "_ML_SRC_FLS" 	"$(_ML_SRC_FLS)"
	@printf $(FMT_VAR_OUT) "ML_OUT_FLS" 	"$(ML_OUT_FLS)"
endif
	@printf $(FMT_VAR_SRC) "_DEP_FLS" 		"$(_DEP_FLS)"
ifdef THUMB_OUT_DIR
	@printf $(FMT_VAR_SRC) "THUMB_OUT_DIR" 	"$(THUMB_OUT_DIR)"
	@printf $(FMT_VAR_OUT) "_THUMB_FLS" 	"$(_THUMB_FLS)"
	@printf $(FMT_VAR_OUT) "THUMB_OUT_FLS"  "$(THUMB_OUT_FLS)"
	@printf $(FMT_VAR_OUT) "THUMB_OUT_DIRS" "$(THUMB_OUT_DIRS)"
endif
	@# @printf $(FMT_VAR_SRC) "y" 		"$(y)"

# DIRECTORIES
$(sort $(ML_OUT_DIRS) $(_DEP_DIRS) $(RES_OUT_DIRS) $(OUT_DIRS) $(THUMB_OUT_DIRS)):
	@printf $(FMT_DIR) "$@"
	@mkdir -p $@

# MULTILANG RULES
ifdef COMMON_DIR
# $@ is the target to trigger the rule, but all languages have to be built now
$(foreach out_dir, $(ML_OUT_LANG_DIRS), $(out_dir)/%.html): $(_COMMON_DIR)/%.html | $(ML_OUT_DIRS) $(_DEP_DIRS)
	@RAW_TARGET=`echo $@ $(foreach lang, $(LANGS), | sed 's|$(ML_OUT_DIR)/$(lang)/||')`;\
	for lang in $(LANGS); do \
		target=$(ML_OUT_DIR)/$$lang/$$RAW_TARGET;\
		printf $(FMT_OUT_ML_HTML) "$$lang" "$<" "$$target"; \
		$(HTML_PP_CMD) --input "$<" --output "$$target" --var include_dir=$(_INCLUDE_DIR) --var lang=$$lang --output-deps "`echo $${target}.d | sed 's|$(OUT_DIR)/|$(DEP_DIR)/|'`"; \
	done


# rule for all not html files
$(foreach out_dir, $(ML_OUT_LANG_DIRS), $(out_dir)/%): $(_COMMON_DIR)/% | $(ML_OUT_DIRS)
	@lang=`echo $(patsubst $(ML_OUT_DIR)/%, %, $@) | awk -F "/" '{print $$1}'`; \
	printf $(FMT_OUT_ML_OTHER) "$$lang" "$<" "$@" ; \
	cp $< $@
endif

# THUMBNAILS
$(OUT_DIR)/$(THUMB_OUT_DIR)/%.jpg: | $(THUMB_OUT_DIRS)
	@fulltarget="$@"; \
	target="$(patsubst $(OUT_DIR)/$(THUMB_OUT_DIR)/%.jpg,%,$@)"; \
	sources=($(_THUMB_FLS)); \
	source=$$(printf  "%s\n" $${sources[@]} | grep "$$target"'\.'); \
	printf $(FMT_OUT_THUMB) "$$source" "$$fulltarget"; \
	if [ "$${source##*.}" = "pdf" ]; then \
		pdftoppm -f 1 -singlefile -jpeg -r 50 "$$source" "$${fulltarget%.*}"; \
	else \
		magick "$$source" -thumbnail '100x100>' "$@"; \
	fi; \




#
# (NORMAL/RE-)SOURCE RULES
# 
$(OUT_DIR)/%.html: $(PROJECT_DIR)/%.html | $(OUT_DIRS) $(_DEP_DIRS)
	@printf $(FMT_OUT_HTML) "$<" "$@";
	@$(HTML_PP_CMD) --input "$<" --output "$@" --var include_dir=$(_INCLUDE_DIR) --output-deps "$(subst $(DEP_DIR)/$(PROJECT_DIR), $(DEP_DIR), $(DEP_DIR)/$<.d)";
	@# remove comments and empty lines. two separate lines bc the substitution might create new empty lines
	@#awk -i inplace '{FS="" sub(/<!--.*-->/,"")}1' $@
	@#awk -i inplace '{if (NF != 0) print}' $@

$(OUT_DIR)/%: $(PROJECT_DIR)/% | $(OUT_DIRS) $(RES_OUT_DIRS)
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
	-rm $(OUT_FLS) $(ML_OUT_FLS) 2>/dev/null
	-rm -r $(DEP_DIR) 2>/dev/null

cleaner:
	-rm -r $(OUT_DIR)
