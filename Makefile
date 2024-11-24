# ABOUT In this Makefile, 'building a file' means: - if the file has a '.html' extension: run the html preprocessor on the file and place the output in the output directory
# 	- elif the file has a '.sass' or '.scss' extension: run the sass compiler on the file and place the output in the output directory
# 	- else: copy the file to the output directory
# - Folder structure from source directories will be preserved in the output directory
# - Abbreviations:
#   - FLS: files
#   - DIR: directory
#   - SRC: source
#   - LANG: language
#   - PP: preprocessor
#   - DEP: dependency

#
# NORMAL SETTINGS
# change these to fir your project
#

# root dir for the project, most other paths are relative to PROJECT_DIR
# [absolute or relative to current working directory]
PROJECT_DIR 	= src

# path where final website will be in
# [absolute or relative to current working directory]
OUT_DIR 		= build

# SOURCE FILES:
# all SRC_FLS and all files (recursively) in the SRC_DIRS will be built
# all files in PROJECT_DIR (not recursively) are source files
# [relative to PROJECT_DIR]
SRC_DIRS 		= de en script
SRC_FLS 		= 

# CSS FILES:
# directories which may contain sass and scss to compile sass to a correspondig css in OUT_DIR/CSS_DIR (also css, it will simply be copied)
# [relative to PROJECT_DIR]
CSS_DIRS		= style
CSS_FILES 		= 

# RESOURCE FILES:
# all RESOURCE_FLS and all files in the RESOURCE_DIRS will be copied to OUT_DIR
# [relative to PROJECT_DIR]
RESOURCE_DIRS 	= resources 
RESOURCE_FLS	= 

# MULTI-LANG SOURCE FILES:
# the files in COMMON_DIR will be built for all LANGS:
# for example:
# 	LANGS = de en
# 	PROJECT_DIR/COMMON_DIR/home.html
# 	-> OUT_DIR/de/home.html
# 	-> OUT_DIR/en/home.html
# foreach html-file in COMMON_DIR:
# 	foreach lang in LANGS:
# 		run HTML_PP_CMD with --var lang=lang on file and output to OUT_DIR without the COMMON_DIR prefix, so COMMON_DIR/subdir/file.html -> OUT_DIR/lang/subdir/file.html
# For all .html files, the proprocessor will make the variable `lang` available, for example lang=de
# All non-html files will handled the same way, but without the preprocessor being run on them. They are simply copied.
# leave COMMON_DIR blank to disable multi-lang feature
# [relative to PROJECT_DIR]
COMMON_DIR 		= common
LANGS 			= de en

# FAVICON
# image from which the favicons will be generated
# leave FAVICON blank to not generate favicons
# [relative to PROJECT_DIR]
FAVICON				= resources/favicon.png
# directory where all genreated favicons will be placed
# [relative to OUT_DIR]
FAVICON_OUT_DIR		= favicon
# in addition to the ones below, a favicon.ico containing the 16x16, 32x32 and 48x48will be generated
# all apple-touch-icon-XXxXX.png sizes
APPLE_ICON_SIZES 	= 180x180
# all mstile-XXxXX.png sizes
WINDOWS_ICON_SIZES 	= 150x150
# all android-chrome-XXxXX.png sizes
ANDROID_ICON_SIZES 	= 192x192 512x512
# all favicon-XXxXX.png sizes
FAVICON_ICON_SIZES 	= 16x16 32x32 48x48

# THUMBNAILS and OPTIMIZED IMAGES:
# In the source paths _FLS and _DIRS, the redundant '/./' will be replaced by /_OUT_DIR/
# This way leaves more control over where the thumbanils/optimized images will be placed.

# THUMBNAILS
# Thumbnails for THUMB_FLS and all files in THUMB_DIRS (recursively) having an extension in THUMB_FOR_TYPES 
# will be generated.
# example:
# 	THUMB_DIRS 		= resources/./video ././resources/music
# 	THUMB_OUT_DIR 	= thumbnails
# 	resources/video/cool-video.mp4 	-> resources/thumbnails/video/cool-video.webp
# 	resources/music/song.mp3 		-> thumbnails/resources/music/song.webp
THUMB_FLS  		=
THUMB_DIRS  	= resources/./
# Substitution for /./ in THUMB_FLS and THUMB_DIRS
THUMB_OUT_DIR 	= thumbnails
# build thumbnails for these types: supported: mp3, flac, wav, pdf and all image formats that magick can handle
THUMB_FOR_TYPES 	= pdf mp4 mp3 flac wav
# filetype for the thumbnails
THUMB_TYPE 	= webp
# size for the thumbnails, the larger dimension will have this size
THUMB_SIZE 	= 400

# OPTIMIZED IMAGES
# A optimized image version will be generated for all images in OPTIMIZED_IMG_FLS and in OPTIMIZED_IMG_DIRS (recursively) 
# having an extension in OPTIMIZED_IMG_FOR_TYPES 
OPTIMIZED_IMG_FLS 		= 
OPTIMIZED_IMG_DIRS 		= resources/./
# Substitution for /./ in OPTIMIZED_IMG_FLS and OPTIMIZED_IMG_DIRS
OPTIMIZED_IMG_OUT_DIR	= optim
OPTIMIZED_IMG_FOR_TYPES = png gif jpg jpeg
OPTIMIZED_IMG_TYPE 		= webp
OPTIMIZED_IMG_QUALITY	= 80

# SITEMAP
# leave SITEMAP blank to not generate a sitemap 
# [relative to OUT_DIR]
SITEMAP 			= sitemap.xml 
# base url of the website, without trailing /
WEBSITE_URL 		= https://quintern.xyz
# file required during build process for sitemap generation [absolute or relative to current working directory]
SITEMAP_TEMP_FILE 	= .sitemap.pkl
# comment to keep the file extension on sitemap entries
SITEMAP_REMOVE_EXT  = 1

# PREPROCESSOR
# path to of the files that should be included
# [relative to PROJECT_DIR]
INCLUDE_DIR 	= include
# additional search paths passed to sass compiler
# [relative to PROJECT_DIR]
SASS_INCLUDE_DIRS	= include/style


# ADVANCED
# the command to run the html preprocessor
HTML_PP_CMD 	= python3 html-preprocessor --exit-on light
# command to compile sass and scss files with
# --indented is added for sass and --no-indented for scss
# --source-maps-urls=absolute is appended for generating dependency files
SASS_CMD 		= sass --color

OPTIMIZED_IMG_CMD 	= magick -quality $(OPTIMIZED_IMG_QUALITY)

# [absolute or relative to current working directory]
DEP_DIR 		= .dependencies

# required for thumbnail creation
TMP_DIR			= /tmp


#
# NOT SETTINGS ANYMORE
# DO NOT CHANGE ANYTHING HERE UNLESS YOU KNOW WHAT YOU ARE DOING!
#
# all variables starting with _ are relative to PROJECT_DIR

# make everything relative to PROJECT_DIR
_SRC_DIRS 		= $(addprefix $(PROJECT_DIR)/, $(SRC_DIRS))
_SRC_FLS 		= $(addprefix $(PROJECT_DIR)/, $(SRC_FLS))
_CSS_FLS 		= $(addprefix $(PROJECT_DIR)/, $(CSS_FLS))
_CSS_DIRS 		= $(addprefix $(PROJECT_DIR)/, $(CSS_DIRS))
_SASS_INCLUDE_DIRS = $(addprefix $(PROJECT_DIR)/, $(SASS_INCLUDE_DIRS))
_RES_DIRS 		= $(addprefix $(PROJECT_DIR)/, $(RESOURCE_DIRS))
_RES_FLS 		= $(addprefix $(PROJECT_DIR)/, $(RESOURCE_FLS))
_OPTIMIZED_IMG_DIRS = $(addprefix $(PROJECT_DIR)/, $(OPTIMIZED_IMG_DIRS))
_OPTIMIZED_IMG_FLS = $(addprefix $(PROJECT_DIR)/, $(OPTIMIZED_IMG_FLS))
_THUMB_DIRS		= $(addprefix $(PROJECT_DIR)/, $(THUMB_DIRS))
_THUMB_FLS 		= $(addprefix $(PROJECT_DIR)/, $(THUMB_FLS))
_COMMON_DIR 	= $(addprefix $(PROJECT_DIR)/, $(COMMON_DIR))
_INCLUDE_DIR 	= $(addprefix $(PROJECT_DIR)/, $(INCLUDE_DIR))

# NORMAL SRC
# all SRC_DIRS + CSS_DIRS + all subdirs of each srcdir
_SRC_SUB_DIRS 	= $(foreach srcdir, $(_SRC_DIRS) $(_CSS_DIRS), $(shell find $(srcdir)/ -type d 2>/dev/null))
# add files in project dir
_SRC_FLS		+= $(shell find $(PROJECT_DIR)/ -maxdepth 1 -type f)
# add files src dirs, recursively
_SRC_FLS		+= $(foreach srcdir, $(_SRC_DIRS), $(shell find $(srcdir)/ -type f 2>/dev/null))
_CSS_FLS		+= $(foreach srcdir, $(_CSS_DIRS), $(shell find $(srcdir)/ -type f 2>/dev/null))

OUT_DIRS 		= $(OUT_DIR)/ $(patsubst $(PROJECT_DIR)/%, $(OUT_DIR)/%, $(_SRC_SUB_DIRS)) 
# path of the (css/sass) source files after being processed
OUT_FLS 		= $(patsubst $(PROJECT_DIR)/%, $(OUT_DIR)/%, $(_SRC_FLS)) 
OUT_FLS			+= $(patsubst $(PROJECT_DIR)/%, $(OUT_DIR)/%, $(foreach cssfile, $(_CSS_FLS), $(shell echo $(cssfile) | sed 's/\.s[ac]ss$$/.css/')))

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

ifdef FAVICON_OUT_DIR
__FAVICON_OUT_DIR = $(addprefix $(OUT_DIR)/,$(FAVICON_OUT_DIR))
else
__FAVICON_OUT_DIR = $(OUT_DIR)
endif

ifdef FAVICON
_FAVICON 		= $(addprefix $(PROJECT_DIR)/,$(FAVICON))
FAVICON_ICO		= $(__FAVICON_OUT_DIR)/favicon.ico
APPLE_ICONS 	= $(addsuffix .png,$(addprefix apple-touch-icon-,$(APPLE_ICON_SIZES)))
WINDOWS_ICONS 	= $(addsuffix .png,$(addprefix mstile-,$(WINDOWS_ICON_SIZES)))
ANDROID_ICONS 	= $(addsuffix .png,$(addprefix android-chrome-,$(ANDROID_ICON_SIZES)))
FAVICON_ICONS 	= $(addsuffix .png,$(addprefix favicon-,$(FAVICON_ICON_SIZES)))
FAVICONS_PNG	= $(addprefix $(__FAVICON_OUT_DIR)/,$(APPLE_ICONS) $(WINDOWS_ICONS) $(ANDROID_ICONS) $(FAVICON_ICONS))
FAVICONS 		= $(FAVICONS_PNG) $(FAVICON_ICO) 
endif

_THUMB_FLS			+= $(foreach srcdir, $(_THUMB_DIRS), $(shell find $(subst //,/,$(srcdir)/) -type f 2>/dev/null))
# files for which to generate thumbnails
_THUMB_FLS_FILTERED	= $(filter $(foreach type, $(THUMB_FOR_TYPES), %.$(type)), $(_THUMB_FLS))
THUMB_OUT_FLS 		= $(addsuffix .$(THUMB_TYPE), $(basename $(subst /./,/$(THUMB_OUT_DIR)/,$(patsubst $(PROJECT_DIR)/%, $(OUT_DIR)/%, $(_THUMB_FLS_FILTERED)))))
THUMB_OUT_DIRS		= $(sort $(dir $(THUMB_OUT_FLS)))  # sort for removing duplicates

_OPTIMIZED_IMG_FLS			+= $(foreach srcdir, $(_OPTIMIZED_IMG_DIRS), $(shell find $(subst //,/,$(srcdir)) -type f 2>/dev/null))
_OPTIMIZED_IMG_FLS_FILTERED += $(filter $(foreach type, $(OPTIMIZED_IMG_FOR_TYPES), %.$(type)), $(_OPTIMIZED_IMG_FLS))
OPTIMIZED_IMG_OUT_FLS 		= $(addsuffix .$(OPTIMIZED_IMG_TYPE), $(basename $(subst /./,/$(OPTIMIZED_IMG_OUT_DIR)/,$(patsubst $(PROJECT_DIR)/%, $(OUT_DIR)/%, $(_OPTIMIZED_IMG_FLS_FILTERED)))))
OPTIMIZED_IMG_OUT_DIRS		= $(sort $(dir $(OPTIMIZED_IMG_OUT_FLS)))  # sort for removing duplicates

# needed for creating them
_DEP_DIRS 		= $(sort $(patsubst $(OUT_DIR)/%, $(DEP_DIR)/%, $(OUT_DIRS) $(ML_OUT_DIRS)))
# needed for reading
_DEP_FLS 		= $(shell find $(DEP_DIR) -type f -name '*.d' 2>/dev/null)

ifdef SITEMAP
	SITEMAP_OUT	= $(addprefix $(OUT_DIR)/, $(SITEMAP))
	HTML_PP_CMD += --sitemap-temp-file "$(SITEMAP_TEMP_FILE)" --sitemap-base-url $(WEBSITE_URL) --sitemap-webroot-dir "$(OUT_DIR)"
endif
ifdef SITEMAP_REMOVE_EXT
	HTML_PP_CMD += --sitemap-remove-ext
endif
# SASS, add load-paths
_SASS_CMD 		= $(SASS_CMD) $(foreach includedir, $(_SASS_INCLUDE_DIRS), --load-path=$(includedir)) --source-map-urls=absolute

# PRINTING
FMT_VAR_SRC		="Variable '\e[1;34m%s\e[0m': \e[0;33m%s\e[0m\n"
FMT_VAR_OUT		="Variable '\e[1;34m%s\e[0m': \e[0;35m%s\e[0m\n"
FMT_DIR			="\e[1;34mMaking directory\e[0m: \e[0;35m%s\e[0m\n"
FMT_OUT_HTML	="\e[1;34mBuilding html\e[0m: \e[1;33m%s\e[0m at \e[1;35m%s\e[0m\n"
FMT_OUT_CSS   	="\e[1;34mBuilding css\e[0m: \e[1;33m%s\e[0m at \e[1;35m%s\e[0m\n"
FMT_OUT_THUMB	="\e[1;34mGenerating thumbnail\e[0m: \e[1;33m%s\e[0m at \e[1;35m%s\e[0m\n"
FMT_OUT_OPTIMIZED_IMG	="\e[1;34mGenerating optimized image\e[0m: \e[1;33m%s\e[0m at \e[1;35m%s\e[0m\n"
FMT_OUT_SITEMAP	="\e[1;34mGenerating sitemap\e[0m: \e[1;35m%s\e[0m\n"
FMT_OUT_FAVICON	="\e[1;34mGenerating favicon\e[0m: \e[1;33m%s\e[0m at \e[1;35m%s\e[0m\n"
FMT_OUT_OTHER	="\e[1;34mBuilding\e[0m: \e[1;33m%s\e[0m at \e[1;35m%s\e[0m\n"
FMT_OUT_ML_HTML ="\e[1;34mBuilding html\e[0m in lang \e[1;34m%s\e[0m: \e[1;33m%s\e[0m at \e[1;35m%s\e[0m\n"
FMT_OUT_ML_OTHER ="\e[1;34mBuilding\e[0m in lang \e[1;34m%s\e[0m: \e[1;33m%s\e[0m at \e[1;35m%s\e[0m\n"
# .SUFFIXES:
# .SUFFIXES: .html .md

.PHONY: default normal multilang resources sitemap favicons thumbnails images print start stop clean cleaner

.DEFAULT_GOAL 	= all

# include all the dependency makefiles
include $(_DEP_FLS)

all: normal multilang resources thumbnails sitemap favicons images
normal:	$(OUT_FLS)
sitemap: $(SITEMAP_OUT)
favicons: $(FAVICONS) $(FAVICON_ICO)
multilang: $(ML_OUT_FLS)
resources: $(RES_OUT_FLS)
thumbnails: $(THUMB_OUT_FLS)
images: $(OPTIMIZED_IMG_OUT_FLS)

print:
	@printf $(FMT_VAR_SRC) "PROJECT_DIR" 	"$(PROJECT_DIR)"
	@printf $(FMT_VAR_OUT) "OUT_DIRS" 		"$(OUT_DIRS)"
	@printf $(FMT_VAR_SRC) "_INCLUDE_DIR" 	"$(_INCLUDE_DIR)"
	@printf $(FMT_VAR_SRC) "_SRC_FLS" 		"$(_SRC_FLS)"
	@printf $(FMT_VAR_OUT) "OUT_FLS" 		"$(OUT_FLS)"
	@printf $(FMT_VAR_SRC) "_RES_FLS" 		"$(_RES_FLS)"
	@printf $(FMT_VAR_OUT) "RES_OUT_FLS" 	"$(RES_OUT_FLS)"
	@printf $(FMT_VAR_OUT) "_CSS_FLS" 		"$(_CSS_FLS)"
ifdef COMMON_DIR
	@printf $(FMT_VAR_SRC) "_ML_SRC_FLS" 	"$(_ML_SRC_FLS)"
	@printf $(FMT_VAR_OUT) "ML_OUT_FLS" 	"$(ML_OUT_FLS)"
endif
	@printf $(FMT_VAR_SRC) "_DEP_FLS" 		"$(_DEP_FLS)"
ifdef THUMB_OUT_DIR
	@printf $(FMT_VAR_SRC) "THUMB_OUT_DIR" 	"$(THUMB_OUT_DIR)"
	@printf $(FMT_VAR_OUT) "_THUMB_FLS_FILTERED" 	"$(_THUMB_FLS_FILTERED)"
	@printf $(FMT_VAR_OUT) "THUMB_OUT_FLS"  "$(THUMB_OUT_FLS)"
	@printf $(FMT_VAR_OUT) "THUMB_OUT_DIRS" "$(THUMB_OUT_DIRS)"
endif
ifdef OPTIMIZED_IMG_OUT_DIR
	@printf $(FMT_VAR_SRC) "OPTIMIZED_IMG_OUT_DIR" 	"$(OPTIMIZED_IMG_OUT_DIR)"
	@printf $(FMT_VAR_OUT) "_OPTIMIZED_IMG_FLS_FILTERED" 	"$(_OPTIMIZED_IMG_FLS_FILTERED)"
	@printf $(FMT_VAR_OUT) "OPTIMIZED_IMG_OUT_FLS"  "$(OPTIMIZED_IMG_OUT_FLS)"
	@printf $(FMT_VAR_OUT) "OPTIMIZED_IMG_OUT_DIRS" "$(OPTIMIZED_IMG_OUT_DIRS)"
endif
	@# @printf $(FMT_VAR_SRC) "y" 		"$(y)"

# DIRECTORIES
$(sort $(ML_OUT_DIRS) $(_DEP_DIRS) $(RES_OUT_DIRS) $(OUT_DIRS) $(THUMB_OUT_DIRS) $(OPTIMIZED_IMG_OUT_DIRS) $(__FAVICON_OUT_DIR)):
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

ifdef FAVICONS
# must be first
$(FAVICON_ICO): $(_FAVICON) | $(__FAVICON_OUT_DIR)
	@printf $(FMT_OUT_FAVICON) "$<" "$@"
	@magick "$<" -define icon:auto-resize=16,32,48 "$@"

$(FAVICONS_PNG): $(_FAVICON) | $(__FAVICON_OUT_DIR)
	@printf $(FMT_OUT_FAVICON) "$<" "$@"
	@# resize to 512x512 and pad with transparency in case resize did not resize to correct size
	@size=$$(echo "$@" | grep -o -P '\d{2,4}x\d{2,4}');\
	magick "$<" -resize "$${size}" -background none -gravity center -extent "$${size}" "$@"
endif


# THUMBNAILS
$(THUMB_OUT_FLS): | $(THUMB_OUT_DIRS) $(TMP_DIR)
	@sources=($(foreach f,$(_THUMB_FLS_FILTERED), "$(f)")); \
	targets=($(foreach f,$(THUMB_OUT_FLS), "$(f)")); \
	index=$$(printf "%s\n" "$${targets[@]}" | awk '$$0 == "$@" {print NR-1}'); \
	source="$${sources[$$index]}"; \
	printf $(FMT_OUT_THUMB) "$$source" "$@"; \
	case "$${source##*.}" in \
	"mp4-use-magick-as-well") ffmpegthumbnailer -i "$$source" -o "$@" -s 300 -q 5;; \
	"pdf") \
		pdftoppm -f 1 -singlefile -jpeg -r 50 "$$source" "$(TMP_DIR)/buwuma-pdf"; \
		magick "$(TMP_DIR)/buwuma-pdf.jpg" -thumbnail '$(THUMB_SIZE)x$(THUMB_SIZE)>' "$@"; \
		rm "$(TMP_DIR)/buwuma-pdf.jpg"; \
		;; \
	"mp3"|"flac"|"wav") ffmpeg -hide_banner -i "$$source" "$@" -y >/dev/null;; \
	*) magick "$${source}[0]" -thumbnail '$(THUMB_SIZE)x$(THUMB_SIZE)>' "$@";; \
	esac

# OPTIMIZED IMAGES
$(OPTIMIZED_IMG_OUT_FLS): | $(OPTIMIZED_IMG_OUT_DIRS)
	@sources=($(foreach f,$(_OPTIMIZED_IMG_FLS_FILTERED), "$(f)")); \
	targets=($(foreach f,$(OPTIMIZED_IMG_OUT_FLS), "$(f)")); \
	index=$$(printf "%s\n" "$${targets[@]}" | awk '$$0 == "$@" {print NR-1}'); \
	source="$${sources[$$index]}"; \
	printf $(FMT_OUT_OPTIMIZED_IMG) "$$source" "$@"; \
	$(OPTIMIZED_IMG_CMD) "$${source}[0]" "$@"

# SITEMAP
ifdef SITEMAP_OUT
$(SITEMAP_OUT): $(OUT_FLS)  $(ML_OUT_FLS)  # build sitemap after all other files
	@printf $(FMT_OUT_SITEMAP) "$@"
	@$(HTML_PP_CMD) --sitemap-generate "$@"
endif


#
# (NORMAL/RE-)SOURCE RULES
# 
$(OUT_DIR)/%.html: $(PROJECT_DIR)/%.html | $(OUT_DIRS) $(_DEP_DIRS)
	@printf $(FMT_OUT_HTML) "$<" "$@";
	@$(HTML_PP_CMD) --input "$<" --output "$@" --var include_dir=$(_INCLUDE_DIR) --output-deps "$(subst $(DEP_DIR)/$(PROJECT_DIR), $(DEP_DIR), $(DEP_DIR)/$<.d)";
	@# remove comments and empty lines. two separate lines bc the substitution might create new empty lines
	@#awk -i inplace '{FS="" sub(/<!--.*-->/,"")}1' $@
	@#awk -i inplace '{if (NF != 0) print}' $@


# SASS
$(OUT_DIR)/%.css: $(PROJECT_DIR)/%.sass | $(OUT_DIRS) $(_DEP_DIRS)
	@printf $(FMT_OUT_CSS) "$<" "$@";
	@$(_SASS_CMD) --indented "$<" "$@" || { rm "$@"; exit 1; }
	@depfile=$(patsubst $(OUT_DIR)/%,$(DEP_DIR)/%,$@).d; echo -n  "$@: " > "$$depfile"; \
		jq -r '.sources | @sh' $@.map | tr -d \' | sed 's|file://||g' >> "$$depfile"; \
		rm $@.map
	@# generate a dependecy file from the source map and delete the map

# SCSS
$(OUT_DIR)/%.css: $(PROJECT_DIR)/%.scss | $(OUT_DIRS) $(_DEP_DIRS)
	@printf $(FMT_OUT_CSS) "$<" "$@";
	@$(_SASS_CMD) --no-indented "$<" "$@" || { rm "$@"; exit 1; }
	@# generate a dependecy file from the source map and delete the map
	@depfile=$(patsubst $(OUT_DIR)/%,$(DEP_DIR)/%,$@).d; echo -n  "$@: " > "$$depfile"; \
		jq -r '.sources | @sh' $@.map | tr -d \' | sed 's|file://||g' >> "$$depfile"; \
		rm $@.map

# this rule must be last!
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
	-@rm $(OUT_FLS) $(ML_OUT_FLS) $(SITEMAP_TEMP_FILE) $(SITEMAP) 2>/dev/null
	-@rm -r $(DEP_DIR) 2>/dev/null

cleaner:
	-@rm -r $(OUT_DIR)
	-@rm -r $(DEP_DIR) 2>/dev/null
