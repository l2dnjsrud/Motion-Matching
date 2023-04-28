PLATFORM ?= PLATFORM_DESKTOP
BUILD_MODE ?= RELEASE
RAYLIB_DIR = C:/Users/hjtwi/raylib
INCLUDE_DIR = -I ./ -I $(RAYLIB_DIR)/raylib/src -I $(RAYLIB_DIR)/raygui/src
LIBRARY_DIR = -L $(RAYLIB_DIR)/raylib/src
DEFINES = -D _DEFAULT_SOURCE -D RAYLIB_BUILD_MODE=$(BUILD_MODE) -D $(PLATFORM)

ifeq ($(PLATFORM),PLATFORM_DESKTOP)
    CC = g++
    EXT = .exe
    ifeq ($(BUILD_MODE),RELEASE)
        CFLAGS ?= $(DEFINES) -ffast-math -march=native -D NDEBUG -O3 $(RAYLIB_DIR)/raylib/src/raylib.rc.data $(INCLUDE_DIR) $(LIBRARY_DIR) 
	else
        CFLAGS ?= $(DEFINES) -g $(RAYLIB_DIR)/raylib/src/raylib.rc.data $(INCLUDE_DIR) $(LIBRARY_DIR) 
	endif
    LIBS = -lraylib -lopengl32 -lgdi32 -lwinmm
endif

ifeq ($(PLATFORM),PLATFORM_WEB)
    CC = emcc
    EXT = .html
    CFLAGS ?= $(DEFINES) $(RAYLIB_DIR)/raylib/src/libraylib.bc -ffast-math -D NDEBUG -O3 -s USE_GLFW=3 -s FORCE_FILESYSTEM=1 -s MAX_WEBGL_VERSION=2 -s ALLOW_MEMORY_GROWTH=1 --preload-file $(dir $<)resources@resources --shell-file ./shell.html $(INCLUDE_DIR) $(LIBRARY_DIR)
endif

SOURCE = $(wildcard *.cpp)
HEADER = $(wildcard *.h)

.PHONY: all

all: controller

controller: $(SOURCE) $(HEADER)
	$(CC) -o $@$(EXT) $(SOURCE) $(CFLAGS) $(LIBS) 

clean:
	rm controller$(EXT)

CC=g++
INCLUDE_DIR = -I./
INCLUDE_DIR+= -I./depends/raylib/raylib/include
INCLUDE_DIR+= -I./depends/raygui/src
LIBRARY_DIR = -L./depends/raylib/raylib
LIBRARY_DIR+= -L./depends/raylib/raylib/external/glfw/src
LIBRARY_LINK = -lraylib -lglfw3 -ldl -pthread
BUILD_DEP = $(INCLUDE_DIR) $(LIBRARY_DIR) $(LIBRARY_LINK)

all: mmatching

clean:
	-rm mmatching

mmatching:
	$(CC) controller.c -o $@ $(BUILD_DEP)

run:
	./mmatching;



build_depends:
	mkdir -p depends/raygui
	mkdir -p depends/raylib
	git clone --depth 1 https://github.com/raysan5/raylib.git depends/raylib
	git clone --depth 1 https://github.com/raysan5/raygui depends/raygui
	cd depends/raylib && cmake . && make

patch-back:
	mv controller.old.c controller.c


.SILENT: clean
