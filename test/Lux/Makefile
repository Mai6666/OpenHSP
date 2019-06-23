TARGET = lux
CXX = g++
SRCS = ../../src/hsp3/linux/hsp3gr_linux.cpp
OBJS = $(SRCS:%.cpp=%.o)
CXXFLAGS = -DLUXTEST -ggdb3 -DHSPLINUX -DHSPRASPBIAN -DHSPDEBUG
LDFLAGS =

.SUFFIXES: .cpp .o
.cpp.o:
	$(CXX) $(CXXFLAGS) -c -o $@ $^

$(TARGET).out: $(TARGET).o $(OBJS)
	$(CXX) $(LDFLAGS) -o $@ $^

.PHONY: clean
clean:
	rm -f $(OBJS) $(TARGET).o $(TARGET).out
