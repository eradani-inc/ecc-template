module.exports = {
    env: {
        es6: true,
        node: true
    },
    parser: '@typescript-eslint/parser',
    parserOptions: {
        project: 'tsconfig.json',
        sourceType: 'module'
    },
    plugins: ['@typescript-eslint', '@typescript-eslint/tslint', 'filenames'],
    rules: {
        '@typescript-eslint/await-thenable': 'error',
        '@typescript-eslint/consistent-type-assertions': 'error',
        '@typescript-eslint/indent': 'off',
        '@typescript-eslint/member-delimiter-style': [
            'off',
            'error',
            {
                multiline: {
                    delimiter: 'none',
                    requireLast: true
                },
                singleline: {
                    delimiter: 'semi',
                    requireLast: false
                }
            }
        ],
        '@typescript-eslint/no-floating-promises': 'error',
        '@typescript-eslint/no-misused-new': 'error',
        '@typescript-eslint/no-unnecessary-qualifier': 'error',
        '@typescript-eslint/no-unnecessary-type-assertion': 'error',
        '@typescript-eslint/prefer-namespace-keyword': 'error',
        '@typescript-eslint/quotes': 'off',
        '@typescript-eslint/semi': ['off', null],
        '@typescript-eslint/space-within-parens': ['off', 'never'],
        '@typescript-eslint/type-annotation-spacing': 'off',
        '@typescript-eslint/unified-signatures': 'error',
        'filenames/match-regex': ['warn', '^[a-z-0-9.]+$'],
        'arrow-parens': ['off', 'as-needed'],
        camelcase: 'warn',
        'capitalized-comments': 'warn',
        curly: ['error', 'multi-line'],
        'eol-last': 'off',
        eqeqeq: ['warn', 'smart'],
        'id-blacklist': ['error', 'number', 'String', 'string', 'Boolean', 'boolean', 'Undefined'],
        'id-match': 'error',
        'linebreak-style': 'off',
        'max-len': 'off',
        'new-parens': 'off',
        'newline-per-chained-call': 'off',
        'no-caller': 'error',
        'no-cond-assign': 'error',
        'no-constant-condition': 'error',
        'no-control-regex': 'error',
        'no-duplicate-imports': 'error',
        'no-empty': 'error',
        'no-eval': 'error',
        'no-extra-semi': 'off',
        'no-fallthrough': 'error',
        'no-invalid-regexp': 'error',
        'no-irregular-whitespace': 'off',
        'no-multiple-empty-lines': 'off',
        'no-redeclare': 'error',
        'no-regex-spaces': 'error',
        'no-return-await': 'error',
        'no-throw-literal': 'error',
        'no-trailing-spaces': 'off',
        'no-unused-expressions': [
            'error',
            {
                allowTaggedTemplates: true,
                allowShortCircuit: true
            }
        ],
        'no-unused-labels': 'error',
        'no-var': 'error',
        'one-var': ['error', 'never'],
        'quote-props': 'off',
        radix: 'error',
        'space-before-function-paren': 'off',
        'spaced-comment': 'error',
        'use-isnan': 'error',
        '@typescript-eslint/tslint/config': [
            'error',
            {
                rules: {
                    'jsdoc-format': true,
                    'no-reference-import': true,
                    'strict-type-predicates': true
                }
            }
        ]
    }
};
