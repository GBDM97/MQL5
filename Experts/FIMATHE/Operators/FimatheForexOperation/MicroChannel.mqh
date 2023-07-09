#include "MacroChannel.mqh"
MacroChannel macroChannel;

class MicroChannel {
public:
    double GetSize(double macroInitRef1,double macroInitRef2,double lastClosePrice,double channelDivider);
};

double MicroChannel::GetSize(double macroInitRef1,double macroInitRef2,double lastClosePrice,double channelDivider) {
    
    double averageMicroChannelSize = macroInitRef1-macroInitRef2/channelDivider;
    return 0.0; //todo
}
