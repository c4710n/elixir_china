// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const defaultTheme = require('tailwindcss/defaultTheme')
const colors = require('tailwindcss/colors')
const plugin = require('tailwindcss/plugin')

module.exports = {
  content: ['../lib/*/**/*.*ex', './{global,lib,pages}/**/*.js'],
  theme: {
    extend: {
      fontFamily: {
        sans: ['InterVariable', ...defaultTheme.fontFamily.sans],
        mono: ['JetBrains MonoVariable', ...defaultTheme.fontFamily.mono],
      },
      colors: {
        brand: '#4e2a8e',
        primary: colors.indigo,
        neutral: colors.slate,
        info: colors.blue,
        success: colors.green,
        danger: colors.red,
      },
    },
  },
  plugins: [
    require('@tailwindcss/typography')({ target: 'legacy' }),
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/line-clamp'),
    plugin(({ addVariant }) => {
      addVariant('phx-loading', ['.phx-loading&', '.phx-loading &'])
      addVariant('phx-connected', ['.phx-connected&', '.phx-connected &'])
      addVariant('phx-error', ['.phx-error&', '.phx-error &'])
      addVariant('phx-no-feedback', ['.phx-no-feedback&', '.phx-no-feedback &'])
      addVariant('phx-click-loading', ['.phx-click-loading&', '.phx-click-loading &'])
      addVariant('phx-submit-loading', ['.phx-submit-loading&', '.phx-submit-loading &'])
      addVariant('phx-change-loading', ['.phx-change-loading&', '.phx-change-loading &'])
    }),
  ],
}
