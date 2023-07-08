class LastClosePrice {
public:
    double D1(void);
    double M15(void);
};

double LastClosePrice::D1(void) {
    double Close[1];
    CopyClose(Symbol(), PERIOD_D1, 1, 1, Close);
    return Close[0];
}

double LastClosePrice::M15(void) {
    double Close[1];
    CopyClose(Symbol(), PERIOD_M15, 1, 1, Close);
    return Close[0];
}
