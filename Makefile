-include .config

ifndef CPU
	CPU := $(shell uname -m | sed -e s/i.86/i386/ -e s/amd64/x86_64/ -e s/sun4u/sparc64/ -e s/arm.*/arm/ -e s/sa110/arm/ -e s/alpha/axp/)
endif

ifndef REV
	REV := $(shell git rev-list HEAD | wc -l | tr -d " ")
endif

ifndef VER
	VER := $(REV)~$(shell git rev-parse --short HEAD)
endif
ifndef YEAR
	YEAR := $(shell date +%Y)
endif

CC ?= gcc
LD ?= ld
WINDRES ?= windres
STRIP ?= strip
RM ?= rm -f

CFLAGS += -O2 -fno-strict-aliasing -g -Wno-unused-but-set-variable -fPIC -MMD $(INCLUDES)
LDFLAGS ?= -shared
LIBS ?= -lm -ldl


HEADERS := \
	a_game.h \
	a_menu.h \
	a_radio.h \
	a_team.h \
	cgf_sfx_glass.h \
	game.h \
	g_local.h \
	m_player.h \
	q_shared.h

OBJS := \
	a_cmds.o \
	a_doorkick.o \
	a_game.o \
	a_items.o \
	a_menu.o \
	a_radio.o \
	a_team.o \
	cgf_sfx_glass.o \
	g_ai.o \
	g_chase.o \
	g_cmds.o \
	g_combat.o \
	g_func.o \
	g_items.o \
	g_main.o \
	g_misc.o \
	g_monster.o \
	g_phys.o \
	g_save.o \
	g_spawn.o \
	g_svcmds.o \
	g_target.o \
	g_trigger.o \
	g_turret.o \
	g_utils.o \
	g_weapon.o \
	m_move.o \
	p_client.o \
	p_hud.o \
	p_trail.o \
	p_view.o \
	p_weapon.o \
	q_shared.o

TARGET ?= game$(CPU)-action-r$(VER).so	

all: $(TARGET)

default: all

# Define V=1 to show command line.
ifdef V
    Q :=
    E := @true
else
    Q := @
    E := @echo
endif

-include $(OBJS:.o=.d)

%.o: %.c $(HEADERS)
	$(E) [CC] $@
	$(Q)$(CC) -c $(CFLAGS) -o $@ $<

%.o: %.rc
	$(E) [RC] $@
	$(Q)$(WINDRES) $(RCFLAGS) -o $@ $<

$(TARGET): $(OBJS)
	$(E) [LD] $@
	$(Q)$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)

clean:
	$(E) [CLEAN]
	$(Q)$(RM) *.o *.d $(TARGET)

strip: $(TARGET)
	$(E) [STRIP]
	$(Q)$(STRIP) $(TARGET)
	
