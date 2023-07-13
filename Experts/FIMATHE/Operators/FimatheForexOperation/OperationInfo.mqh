class OperationInfo {
public:
  double volume;
  enum takeProfitType {
    SURF,
    ONE_LEVEL,
    TWO_LEVELS,
    THREE_LEVELS,
    FOUR_LEVELS
   };
  double stopLossMultiplier;
  double macroInitRef1;
  double macroInitRef2;
  double channelDivider;
};

