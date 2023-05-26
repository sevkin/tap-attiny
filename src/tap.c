#include <avr/io.h>
#include <util/delay.h>

#define LED PB2
#define OUT PB4
#define DELAY 80
#define SENSIVITY 23

int main() {
  ADMUX = _BV(REFS0) |               // Internal voltage reference
          _BV(ADLAR) |               // 10 bit left ajust result ADCH:ADCL
          _BV(MUX1) | _BV(MUX0);     // ADC3 (PB3)
  ADCSRA |= _BV(ADEN) |              // ADC enable
            _BV(ADPS1) | _BV(ADPS0); // Prescaler 8
  // _BV(ADPS2) | _BV(ADPS1) | _BV(ADPS0); // Prescaler 128

  DDRB |= _BV(LED); // Output for LED indication

  DDRB |= _BV(OUT);  // Output for signal pin for sink
  PORTB &= _BV(OUT); // Disable pull-up

  while (1) {
    ADCSRA |= _BV(ADSC); // Start ADC
    while (ADCSRA & _BV(ADSC))
      ; // Wait for completed

    if (ADCH > SENSIVITY) {

      DDRB &= ~_BV(OUT); // Set up OUT as input (open-drain) for Signal pin
      PORTB |= _BV(LED); // Turn LED on

      _delay_ms(DELAY);

      PORTB &= ~_BV(LED); // Turn LED off
      DDRB |= _BV(OUT);   // Set up OUT as output for (sinking)
    }
  }
}
