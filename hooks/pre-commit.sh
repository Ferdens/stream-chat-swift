#!/bin/bash
./hooks/git-format-staged --formatter 'mint run swiftformat --config .swiftformat stdin' 'Sources_v3/*.swift'
./hooks/git-format-staged --formatter 'mint run swiftformat --config .swiftformat stdin' 'Tests_v3/*.swift'
./hooks/git-format-staged --formatter 'mint run swiftformat --config .swiftformat stdin' 'Sample_v3/*.swift'
./hooks/git-format-staged --formatter 'mint run swiftformat --config .swiftformat stdin' 'DemoApp/*.swift'
