class LastClosePrice {
public:
    double M15(void);
};

double LastClosePrice::M15(void) {
    double Close[1];
    CopyClose(Symbol(), PERIOD_M15, 1, 1, Close);
    return Close[0];
}
