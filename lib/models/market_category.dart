enum MarketCategory {
  usdt('USDT'),
  btc('BTC'),
  eth('ETH'),
  bnb('BNB');

  final String label;

  const MarketCategory(this.label);

  bool matches(String symbol) {
    return switch (this) {
      MarketCategory.usdt => symbol.endsWith('USDT'),
      MarketCategory.btc =>
        symbol.endsWith('BTC') && !symbol.endsWith('USDT'),
      MarketCategory.eth =>
        symbol.endsWith('ETH') && !symbol.endsWith('USDT'),
      MarketCategory.bnb =>
        symbol.endsWith('BNB') && !symbol.endsWith('USDT'),
    };
  }
}
