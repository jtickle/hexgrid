var path = require('path');
var webpack = require('webpack');

console.log(__dirname);

module.exports = {
  entry: [
    'babel-polyfill',
    './src/Main',
  ],
  output: {
    publicPath: '/',
    filename: 'hexgrid.js',
  },
  devtool: 'source-map',
  resolve: {
    extensions: ["", ".js", ".coffee"],
    root: [
      path.resolve('./src'),
      path.resolve(),
    ]
  },
  module: {
    loaders: [
      {
        loader: "babel-loader",
        test: /\.jsx?$/,
        query: {
          plugins: ['transform-runtime'],
          presets: ['es2015', 'react'],
        },
      },
      {
        loader: "coffee-loader",
        test: /\.coffee$/,
      },
    ],
  },
  debug: true,
};

module.exports.module.loaders.map(function(v) {
  v.include = [path.resolve('./src')];
});
